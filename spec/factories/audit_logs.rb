FactoryBot.define do
  factory :audit_log do
    user
    action { "update" }
    auditable_type { "Material" }
    auditable_id { 1 }
    changes_json { "{}" }
  end
end
