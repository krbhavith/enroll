module BenefitMarkets
  class BenefitSponsorCatalog
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :benefit_application, class_name: "::BenefitSponsors::BenefitApplications::BenefitApplication"

    field :effective_date,          type: Date 
    field :probation_period_kinds,  type: Array, default: []


    belongs_to  :service_area,
                class_name: "BenefitMarkets::Locations::ServiceArea"

    embeds_one  :sponsor_market_policy,
                class_name: "::BenefitMarkets::MarketPolicies::SponsorMarketPolicy"

    embeds_one  :member_market_policy,
                class_name: "::BenefitMarkets::MarketPolicies::MemberMarketPolicy"

    embeds_many :product_packages, as: :packagable,
                class_name: "::BenefitMarkets::Products::ProductPackage"


    def benefit_kinds
    end

    def product_market_kind
      "shop"
    end
    
    def product_active_year
      benefit_application.effective_period.begin.year
    end

    def products_for(plan_option_kind, plan_option_choice)
      product_package = product_packages.by_kind(plan_option_kind.to_sym).first
      return [] unless product_package

      if plan_option_kind == 'metal_level'
        product_package.products.by_metal_level_kind(plan_option_choice)
      elsif 
        issuer_profile = BenefitSponsors::Organizations::IssuerProfile.find_by_issuer_name(plan_option_choice)
        return [] unless issuer_profile
        product_package.products.by_issuer(issuer_profile.id)
      end
    end
  end
end
