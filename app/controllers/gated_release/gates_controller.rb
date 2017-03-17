module GatedRelease
  class GatesController < ApplicationController
    before_filter :find_gate, except: [:index]

    def index
      @gates = Gate.search(params[:q] || '')
    end

    def close
      @gate.close!
      flash[:notice] = "Gate '#{@gate.name}' closed"
      redirect_to action: :index
    end

    def open
      @gate.open!
      flash[:notice] = "Gate '#{@gate.name}' opened"
      redirect_to action: :index
    end

    def limit
      @gate.limit!
      flash[:notice] = "Gate '#{@gate.name}' limited"
      redirect_to action: :index
    end

    def percentage
      value = params[:value].to_i
      @gate.percentage!(value)
      flash[:notice] = "Gate '#{@gate.name}' #{value}% open"
      redirect_to action: :index
    end

    def allow_more
      more = params[:more].to_i
      @gate.allow_more!(more)
      flash[:notice] = "Allowed #{more} more, for gate '#{@gate.name}'"
      redirect_to action: :index
    end

    private

    def find_gate
      @gate = Gate.find(params[:id])
    end
  end
end
