Rails.application.routes.draw do
  mount GatedRelease::Engine => "/gated_release"
end
