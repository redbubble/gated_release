require "active_record"

module GatedRelease
  class Gate < ActiveRecord::Base
    self.table_name = "gated_release_gates"

    OPEN = 'open'
    CLOSED = 'closed'
    LIMITED = 'limited'
    PERCENTAGE = 'percentage'
    STATES = [OPEN, CLOSED, LIMITED, PERCENTAGE]

    validates_uniqueness_of :name
    validates :state, inclusion: { in: STATES }
    validates :percent_open, :inclusion => 0..100

    def self.get(name)
      find_or_create_by(name: name)
    end

    def allow_more!(count)
      increment!(:max_attempts, count)
    end

    def open!
      update_attributes!(state: OPEN)
    end

    def close!
      update_attributes!(state: CLOSED)
    end

    def limit!
      update_attributes!(state: LIMITED)
    end

    def percentage!(value)
      update_attributes!(state: PERCENTAGE, percent_open: value)
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
      return args[:open] if args.has_key?(:open)
      raise KeyError.new("key not found: :open for gated release: #{name}")
    end

    def get_closed_code(args)
      return args[:closed] if args.has_key?(:closed)
      raise KeyError.new("key not found: :closed for gated release: #{name}")
    end

    def increment_attempts
      increment!(:attempts, 1)
    end
  end
end
