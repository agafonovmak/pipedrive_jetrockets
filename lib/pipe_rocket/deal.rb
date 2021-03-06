require 'pipe_rocket/organization'
require 'pipe_rocket/person'

module PipeRocket
  class Deal < Entity
    attr_accessor :organization, :person

    # Returns hash {custom_field_key: PipeRocket::Field object}
    def self.key_field_hash
      @@key_field_hash ||= Pipedrive.deal_fields.key_field_hash
    end

    def initialize(hash)
      super(hash.except(*Deal.key_field_hash.keys))

      org_id = hash['org_id']
      person_id = hash['person_id']

      assign_custom_fields(Deal.key_field_hash, hash)

      if org_id
        @organization = case org_id
          when Integer
            Pipedrive.organizations.find(org_id)
          when Hash
            Organization.new(org_id)
          else
            nil
          end
      end

      if person_id
        @person = case person_id
          when Integer
            Pipedrive.persons.find(person_id)
          when Hash
            Person.new(person_id)
          else
            nil
          end
        end
    end

    # Returns PipeRocket::Stage object corresponding to current deal stage
    def stage
      Pipedrive.stages.find(self.stage_id)
    end

    # Returns stage name like PipelineName:StageName
    def display_stage_name
      self.stage.display_name
    end

    def files
      mail_files = Pipedrive.deals.deal_mail_messages(self.id).inject([]) do |res, message|
        res + message.files
      end
      Pipedrive.deals.deal_files(self.id) + mail_files
    end
  end
end
