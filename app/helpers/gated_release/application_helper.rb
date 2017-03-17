module GatedRelease
  module ApplicationHelper

    def gate_state(gated_release)
      if gated_release.state == Gate::PERCENTAGE
        "#{gated_release.percent_open}% open"
      else
        gated_release.state.upcase
      end
    end
  end
end
