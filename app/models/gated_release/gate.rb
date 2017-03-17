require "active_record"

module GatedRelease
  class Gate < ApplicationRecord
    self.table_name = "gated_release_gates"

    OPEN = 'open'
    CLOSED = 'closed'
    LIMITED = 'limited'
    PERCENTAGE = 'percentage'
    STATES = [OPEN, CLOSED, LIMITED, PERCENTAGE]

    validates_uniqueness_of :name
    validates :state, inclusion: { in: STATES }
    validates :percent_open, :inclusion => 0..100

    scope :newest_first, -> { order("created_at DESC") }

    def self.search(query)
      query = "%#{query.tr('*','%')}%"
      where('name like ?', query).newest_first
    end

    def self.get(name)
      find_or_create_by(name: name)
    end

    def allow_more!(count)
      increment!(:max_attempts, count)
      self
    end

    def open!
      update_attributes!(state: OPEN)
      self
    end

    def close!
      update_attributes!(state: CLOSED)
      self
    end

    def limit!
      update_attributes!(state: LIMITED)
      self
    end

    def percentage!(value)
      update_attributes!(state: PERCENTAGE, percent_open: value)
      self
    end

    def run(args)
      if self.state == OPEN
        run_open_code(args)
      elsif self.state == PERCENTAGE && Kernel.rand(100) < self.percent_open
        run_open_code(args)
      elsif self.state == LIMITED && self.attempts < self.max_attempts
        increment_attempts
        run_open_code(args)
      else
        get_closed_code(args).call
      end
    end

    private

    def run_open_code(args)
      get_open_code(args).call
    rescue StandardError, ScriptError => e
      close! if args[:close_on_error]
      raise
    end

    def get_open_code(args)
      get_arg(args, :open)
    end

    def get_closed_code(args)
      get_arg(args, :closed)
    end

    def get_arg(args, key)
      unless args.has_key?(key)
        raise KeyError.new("key not found: :#{key} for gated release: #{name}")
      end
      args[key]
    end

    def increment_attempts
      increment!(:attempts, 1)
    end
  end
end
