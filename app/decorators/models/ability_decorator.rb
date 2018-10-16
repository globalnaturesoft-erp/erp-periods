Erp::Ability.class_eval do
  def periods_ability(user)
    
    can :creatable, Erp::Periods::Period do |period|
      if Erp::Core.available?("ortho_k")
        user == Erp::User.get_super_admin or
        user.get_permission(:system, :periods, :periods, :create) == 'yes'
      else
        true
      end
    end
    
    can :updatable, Erp::Periods::Period do |period|
      !period.is_deleted? and
      (
        if Erp::Core.available?("ortho_k")
          user == Erp::User.get_super_admin or
          user.get_permission(:system, :periods, :periods, :update) == 'yes'
        else
          true
        end
      )
    end
    
    can :cancelable, Erp::Periods::Period do |period|
      !period.is_deleted? and
      (
        if Erp::Core.available?("ortho_k")
          user == Erp::User.get_super_admin or
          user.get_permission(:system, :periods, :periods, :delete) == 'yes'
        else
          true
        end
      )
    end
    
  end
end
