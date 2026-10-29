class HomeController < ApplicationController
  def index
    @construction_packages = ConstructionPackage.active
  end
end
