module Cms
  module Slony
    class SlonySetsGenerator < Rails::Generators::Base
      source_root ::File.expand_path('../templates', __FILE__)

      def create
        public_models = Cms::Lib::Modules.public_models.map { |m| m.safe_constantize }.compact
        @public_tables = (public_models.map(&:table_name) + ['ar_internal_metadata', 'schema_migrations']).sort
        @public_sequences = public_models.map { |m| m.sequence_name.sub(/^\w+./, '') }.sort

        template 'slony_sets.conf.erb', 'config/slony/slony_sets.conf'
      end
    end
  end
end
