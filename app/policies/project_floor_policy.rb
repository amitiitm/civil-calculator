# frozen_string_literal: true

class ProjectFloorPolicy < ApplicationPolicy
  include OwnedByProjectPolicy

  class Scope < Scope
    def resolve
      return scope.none if user.nil?

      user.admin? ? scope.all : scope.joins(:project).where(projects: { user_id: user.id })
    end
  end
end
