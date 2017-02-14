namespace :zomeki do
  namespace :db do
    namespace :site do
      desc 'Dump site (options: SITE_ID=x, DIR=x)'
      task :dump => :environment do
        site = Cms::Site.find(ENV['SITE_ID'])
        id_map = load_id_map(site)

        unless check_model_and_id_map_consistency(backup_models, id_map)
          raise "invalid model and ids."
        end

        puts "dumping site id: #{site.id}..."
        backup_models.each do |model|
          path = backup_file_path(site, model.table_name)
          puts "#{id_map[model.table_name].size} rows from #{model.table_name} to '#{path}'"
          data = model.unscoped.where(id: id_map[model.table_name]).copy_to_string
          Util::File.put(path, data: data, mkdir: true)
        end
        puts "done."
      end

      desc 'Dump all sites (options: DIR=x)'
      task :dump_all => :environment do
        Cms::Site.order(:id).each do |site|
          ENV['SITE_ID'] = site.id.to_s
          Rake::Task['zomeki:db:site:dump'].reenable
          Rake::Task['zomeki:db:site:dump'].invoke
        end
      end

      desc 'Restore site  (options: SITE_ID=x, DIR=x)'
      task :restore => :environment do
        site = Cms::Site.find(ENV['SITE_ID'])
        id_map = load_id_map(site)

        unless check_model_and_id_map_consistency(backup_models, id_map)
          raise "invalid model and ids."
        end
        unless check_model_and_file_consistency(backup_models, site)
          raise "invalid model and file."
        end

        puts "restoring site id: #{site.id}..."
        backup_models.each do |model|
          path = backup_file_path(site, model.table_name)
          ids = load_ids_from_dump_file(path)
          puts "#{ids.size} rows from '#{path}' to #{model.table_name}"

          model.unscoped.where(id: id_map[model.table_name]).delete_all
          model.unscoped.where(id: ids).delete_all
          model.copy_from(path)
        end
        puts "done."
      end

      def load_ids_from_dump_file(path)
        require 'csv'
        items = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
        items.map { |item| item[:id] }
      end

      def check_model_and_id_map_consistency(models, id_map)
        models.each do |model|
          return false unless id_map.key?(model.table_name)
        end
        true
      end

      def check_model_and_file_consistency(models, site)
        models.each do |model|
          path = backup_file_path(site, model.table_name)
          return false unless File.exist?(path)
        end
        true
      end

      def backup_file_path(site, table_name)
        base_dir = ENV['DIR'] || ENV['HOME'] || Rails.root
        "#{base_dir}/sites/#{format('%04d', site.id)}/db/#{table_name}.dump"
      end

      def backup_models
        models = [
          # Sys
          Sys::Creator,
          Sys::EditableGroup,
          Sys::Editor,
          Sys::File,
          Sys::Group,
          Sys::Message,
          Sys::ObjectRelation,
          Sys::ObjectPrivilege,
          Sys::OperationLog,
          Sys::ProcessLog,
          Sys::Process,
          Sys::Publisher,
          Sys::Recognition,
          Sys::RoleName,
          Sys::Sequence,
          Sys::StorageFile,
          Sys::Task,
          Sys::User,
          Sys::UsersGroup,
          # Cms
          Cms::Bracket,
          Cms::Concept,
          Cms::Content,
          Cms::ContentSetting,
          Cms::DataFileNode,
          Cms::DataFile,
          Cms::DataText,
          Cms::Inquiry,
          Cms::KanaDictionary,
          Cms::Layout,
          Cms::Link,
          Cms::LinkCheckLog,
          Cms::Map,
          Cms::MapMarker,
          Cms::Node,
          Cms::Piece,
          Cms::PieceSetting,
          Cms::PieceLinkItem,
          Cms::Publisher,
          Cms::Site,
          Cms::SiteBelonging,
          Cms::SiteBasicAuthUser,
          Cms::SiteSetting,
          Cms::Stylesheet,
          Cms::TalkTask,
          # AdBanner
          AdBanner::Banner,
          AdBanner::Click,
          AdBanner::Group,
          # Approval
          Approval::ApprovalFlow,
          Approval::Approval,
          Approval::ApprovalRequest,
          Approval::ApprovalRequestHistory,
          Approval::Assignment,
          # BizCalendar
          BizCalendar::Place,
          BizCalendar::HolidayType,
          BizCalendar::BussinessHoliday,
          BizCalendar::BussinessHour,
          BizCalendar::ExceptionHoliday,
          # Feed
          Feed::Feed,
          Feed::FeedEntry,
          # Gnav
          Gnav::MenuItem,
          Gnav::CategorySet,
          # GpArticle
          GpArticle::Doc,
          GpArticle::DocsTagTag,
          GpArticle::Hold,
          GpArticle::RelatedDoc,
          # GpCategory
          GpCategory::CategoryType,
          GpCategory::Category,
          GpCategory::Categorization,
          GpCategory::TemplateModule,
          GpCategory::Template,
          # GpTemplate
          GpTemplate::Template,
          GpTemplate::Item,
          # Map
          Map::Marker,
          Map::MarkerIcon,
          # Organization
          Organization::Group,
          # Rank
          Rank::Rank,
          Rank::Category,
          Rank::Total,
          # Reception
          Reception::Course,
          Reception::Open,
          Reception::Applicant,
          Reception::ApplicantToken,
          # Survey
          Survey::Form,
          Survey::Question,
          Survey::FormAnswer,
          Survey::Answer,
          # Tag
          Tag::Tag
        ]

        require 'postgres-copy'
        models.each do |model|
          unless model.respond_to?(:copy_to)
            model.class_eval do
              acts_as_copy_target  # postgres-copy
            end
          end
        end

        models
      end

      def load_id_map(site)
        id_map = HashWithIndifferentAccess.new

        load_ids_from_sys(site, id_map)
        load_ids_from_cms(site, id_map)
        load_ids_from_ad_banner(site, id_map)
        load_ids_from_approval(site, id_map)
        load_ids_from_biz_calendar(site, id_map)
        load_ids_from_feed(site, id_map)
        load_ids_from_gnav(site, id_map)
        load_ids_from_gp_article(site, id_map)
        load_ids_from_gp_calendar(site, id_map)
        load_ids_from_gp_category(site, id_map)
        load_ids_from_gp_template(site, id_map)
        load_ids_from_map(site, id_map)
        load_ids_from_organization(site, id_map)
        load_ids_from_rank(site, id_map)
        load_ids_from_reception(site, id_map)
        load_ids_from_survey(site, id_map)
        load_ids_from_tag(site, id_map)

        load_ids_from_polymorphic_tables(site, id_map)

        id_map
      end

      def load_ids_from_sys(site, id_map)
        id_map[:sys_groups] = Sys::Group.in_site(site).pluck(:id)
        id_map[:sys_messages] = Sys::Message.where(site_id: site.id).pluck(:id)
        id_map[:sys_operation_logs] = Sys::OperationLog.where(site_id: site.id).pluck(:id)
        id_map[:sys_process_logs] = Sys::ProcessLog.where(site_id: site.id).pluck(:id)
        id_map[:sys_processes] = Sys::Process.where(site_id: site.id).pluck(:id)
        id_map[:sys_role_names] = Sys::RoleName.where(site_id: site.id).pluck(:id)
        id_map[:sys_object_privileges] = Sys::ObjectPrivilege.where(role_id: id_map[:sys_role_names]).pluck(:id)
        id_map[:sys_sequences] = Sys::Sequence.where(site_id: site.id).pluck(:id)
        id_map[:sys_storage_files] = Sys::StorageFile.where(Sys::StorageFile.arel_table[:path].matches("#{Rails.root}/sites/#{format('%04d', site.id)}/%")).pluck(:id)
        id_map[:sys_users] = Sys::User.in_site(site).pluck(:id)
        id_map[:sys_users_groups] = Sys::UsersGroup.where(group_id: id_map[:sys_groups]).pluck(:id)
      end

      def load_ids_from_cms(site, id_map)
        id_map[:cms_brackets] = Cms::Bracket.where(site_id: site.id).pluck(:id)
        id_map[:cms_concepts] = Cms::Concept.where(site_id: site.id).pluck(:id)
        id_map[:cms_contents] = Cms::Content.where(site_id: site.id).pluck(:id)
        id_map[:cms_content_settings] = Cms::ContentSetting.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:cms_data_file_nodes] = Cms::DataFileNode.where(site_id: site.id).pluck(:id)
        id_map[:cms_data_files] = Cms::DataFile.where(site_id: site.id).pluck(:id)
        id_map[:cms_data_texts] = Cms::DataText.where(site_id: site.id).pluck(:id)
        id_map[:cms_kana_dictionaries] = Cms::KanaDictionary.where(site_id: site.id).pluck(:id)
        id_map[:cms_layouts] = Cms::Layout.where(site_id: site.id).pluck(:id)
        id_map[:cms_nodes] = Cms::Node.where(site_id: site.id).pluck(:id)
        id_map[:cms_pieces] = Cms::Piece.where(site_id: site.id).pluck(:id)
        id_map[:cms_piece_settings] = Cms::PieceSetting.where(piece_id: id_map[:cms_pieces]).pluck(:id)
        id_map[:cms_piece_link_items] = Cms::PieceLinkItem.where(piece_id: id_map[:cms_pieces]).pluck(:id)
        id_map[:cms_sites] = Cms::Site.where(id: site.id).pluck(:id)
        id_map[:cms_site_belongings] = Cms::SiteBelonging.where(site_id: site.id).pluck(:id)
        id_map[:cms_site_basic_auth_users] = Cms::SiteBasicAuthUser.where(site_id: site.id).pluck(:id)
        id_map[:cms_site_settings] = Cms::SiteSetting.where(site_id: site.id).pluck(:id)
        id_map[:cms_stylesheets] = Cms::Stylesheet.where(site_id: site.id).pluck(:id)
      end

      def load_ids_from_ad_banner(site, id_map)
        id_map[:ad_banner_banners] = AdBanner::Banner.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:ad_banner_clicks] = AdBanner::Click.where(banner_id: id_map[:ad_banner_banners]).pluck(:id)
        id_map[:ad_banner_groups] = AdBanner::Group.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_approval(site, id_map)
        id_map[:approval_approval_flows] = Approval::ApprovalFlow.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:approval_approvals] = Approval::Approval.where(approval_flow_id: id_map[:approval_approval_flows]).pluck(:id)
        id_map[:approval_approval_requests] = Approval::ApprovalRequest.where(approval_flow_id: id_map[:approval_approval_flows]).pluck(:id)
        id_map[:approval_approval_request_histories] = Approval::ApprovalRequestHistory.where(request_id: id_map[:approval_approval_requests]).pluck(:id)
      end

      def load_ids_from_biz_calendar(site, id_map)
        id_map[:biz_calendar_places] = BizCalendar::Place.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:biz_calendar_holiday_types] = BizCalendar::HolidayType.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:biz_calendar_bussiness_holidays] = BizCalendar::BussinessHoliday.where(place_id: id_map[:biz_calendar_places]).pluck(:id)
        id_map[:biz_calendar_bussiness_hours] = BizCalendar::BussinessHour.where(place_id: id_map[:biz_calendar_places]).pluck(:id)
        id_map[:biz_calendar_exception_holidays] = BizCalendar::ExceptionHoliday.where(place_id: id_map[:biz_calendar_places]).pluck(:id)
      end

      def load_ids_from_feed(site, id_map)
        id_map[:feed_feeds] = Feed::Feed.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:feed_feed_entries] = Feed::FeedEntry.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_gnav(site, id_map)
        id_map[:gnav_menu_items] = Gnav::MenuItem.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gnav_category_sets] = Gnav::CategorySet.where(menu_item_id: id_map[:gnav_menu_items]).pluck(:id)
      end

      def load_ids_from_gp_article(site, id_map)
        id_map[:gp_article_docs] = GpArticle::Doc.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gp_article_docs_tag_tags] = GpArticle::DocsTagTag.where(doc_id: id_map[:gp_article_docs]).pluck(:id)
        id_map[:gp_article_related_docs] = GpArticle::RelatedDoc.where(relatable_id: id_map[:gp_article_docs]).pluck(:id)
      end

      def load_ids_from_gp_calendar(site, id_map)
        id_map[:gp_calendar_events] = GpCalendar::Event.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gp_calendar_holidays] = GpCalendar::Holiday.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_gp_category(site, id_map)
        id_map[:gp_category_category_types] = GpCategory::CategoryType.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gp_category_categories] = GpCategory::Category.where(category_type_id: id_map[:gp_category_category_types]).pluck(:id)
        id_map[:gp_category_categorizations] = GpCategory::Categorization.where(category_id: id_map[:gp_category_categories]).pluck(:id)
        id_map[:gp_category_template_modules] = GpCategory::TemplateModule.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gp_category_templates] = GpCategory::Template.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_gp_template(site, id_map)
        id_map[:gp_template_templates] = GpTemplate::Template.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:gp_template_items] = GpTemplate::Item.where(template_id: id_map[:gp_template_templates]).pluck(:id)
      end

      def load_ids_from_map(site, id_map)
        id_map[:map_markers] = Map::Marker.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:map_marker_icons] = Map::MarkerIcon.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_organization(site, id_map)
        id_map[:organization_groups] = Organization::Group.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_rank(site, id_map)
        id_map[:rank_ranks] = Rank::Rank.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:rank_categories] = Rank::Category.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:rank_totals] = Rank::Total.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_reception(site, id_map)
        id_map[:reception_courses] = Reception::Course.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:reception_opens] = Reception::Open.where(course_id: id_map[:reception_courses]).pluck(:id)
        id_map[:reception_applicants] = Reception::Applicant.where(open_id: id_map[:reception_opens]).pluck(:id)
        id_map[:reception_applicant_tokens] = Reception::ApplicantToken.where(open_id: id_map[:reception_opens]).pluck(:id)
      end

      def load_ids_from_survey(site, id_map)
        id_map[:survey_forms] = Survey::Form.where(content_id: id_map[:cms_contents]).pluck(:id)
        id_map[:survey_questions] = Survey::Question.where(form_id: id_map[:survey_forms]).pluck(:id)
        id_map[:survey_form_answers] = Survey::FormAnswer.where(form_id: id_map[:survey_forms]).pluck(:id)
        id_map[:survey_answers] = Survey::Answer.where(form_answer_id: id_map[:survey_form_answers]).pluck(:id)
      end

      def load_ids_from_tag(site, id_map)
        id_map[:tag_tags] = Tag::Tag.where(content_id: id_map[:cms_contents]).pluck(:id)
      end

      def load_ids_from_polymorphic_tables(site, id_map)
        poly_models = {
          Sys::Creator => [:creatable_type, :creatable_id],
          Sys::EditableGroup => [:editable_type, :editable_id],
          Sys::Editor => [:editable_type, :editable_id],
          Sys::File => [:file_attachable_type, :file_attachable_id],
          Sys::ObjectRelation => [:source_type, :source_id],
          Sys::Publisher => [:publishable_type, :publishable_id],
          Sys::Recognition => [:recognizable_type, :recognizable_id],
          Sys::Task => [:processable_type, :processable_id],
          Cms::Inquiry => [:inquirable_type, :inquirable_id],
          Cms::Link => [:linkable_type, :linkable_id],
          Cms::LinkCheckLog => [:link_checkable_type, :link_checkable_id],
          Cms::Map => [:map_attachable_type, :map_attachable_id],
          Cms::Publisher => [:publishable_type, :publishable_id],
          Cms::TalkTask => [:talk_processable_type, :talk_processable_id],
          Approval::Assignment => [:assignable_type, :assignable_id],
          GpArticle::Hold => [:holdable_type, :holdable_id]
        }

        poly_models.each do |model, (ptype, pkey)|
          types = model.group(ptype).pluck(ptype).compact
          id_map[model.table_name] = model.union(
            types.map { |type|  model.where(ptype => type, pkey => id_map[type.tableize.sub('/', '_')]) }
          ).pluck(:id)
        end

        id_map[:cms_map_markers] = Cms::MapMarker.where(map_id: id_map[:cms_maps]).pluck(:id)
      end
    end
  end
end
