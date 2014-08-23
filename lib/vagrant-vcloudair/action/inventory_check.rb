require 'etc'

module VagrantPlugins
  module VCloudAir
    module Action
      class InventoryCheck
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_vcloudair::action::inventory_check')
        end

        def call(env)
          vcloud_check_inventory(env)

          @app.call env
        end

        def vcloud_upload_box(env)
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          box_dir = env[:machine].box.directory.to_s

          if env[:machine].box.name.to_s.include? '/'
            box_file = env[:machine].box.name.rpartition('/').last.to_s
            box_name = env[:machine].box.name.to_s
          else
            box_file = env[:machine].box.name.to_s
            box_name = box_file
          end

          box_ovf = "#{box_dir}/#{box_file}.ovf"

          # Still relying on ruby-progressbar because report_progress
          # basically sucks.
          @logger.debug("OVF File: #{box_ovf}")
          upload_ovf = cnx.upload_ovf(
            cfg.vdc_id,
            box_name,
            'Vagrant Box',
            box_ovf,
            cfg.catalog_id,
            {
              :progressbar_enable => true,
              # Set the chunksize for upload at the configured value or default
              # to 5M
              :chunksize => (cfg.upload_chunksize || 5_242_880)
            }
          )

          env[:ui].info(I18n.t('vagrant_vcloudair.catalog.add_to_catalog',
                               box_name: box_name,
                               catalog_name: cfg.catalog_name))

          add_ovf_to_catalog = cnx.wait_task_completion(upload_ovf)

          unless add_ovf_to_catalog[:errormsg].nil?
            fail Errors::CatalogAddError,
                 :message => add_ovf_to_catalog[:errormsg]
          end

          # Retrieve catalog_item ID
          cfg.catalog_item = cnx.get_catalog_item_by_name(
            cfg.catalog_id,
            box_name
          )
        end

        def vcloud_create_catalog(env)
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          catalog_creation = cnx.create_catalog(
            cfg.org_id,
            cfg.catalog_name,
            "Created by #{Etc.getlogin} " +
            "running on #{Socket.gethostname.downcase} " +
            "using vagrant-vcloudair on #{Time.now.strftime("%B %d, %Y")}"
          )
          cnx.wait_task_completion(catalog_creation[:task_id])

          @logger.debug("Catalog Creation result: #{catalog_creation.inspect}")
          env[:ui].info(I18n.t('vagrant_vcloudair.catalog.create_catalog',
                               catalog_name: cfg.catalog_name))

          cfg.catalog_id = catalog_creation[:catalog_id]
        end

        def vcloud_check_inventory(env)
          # Will check each mandatory config value against the vCloud Air
          # Instance and will setup the global environment config values
          cfg = env[:machine].provider_config
          cnx = cfg.vcloudair_cnx.driver

          if env[:machine].box.name.to_s.include? '/'
            box_file = env[:machine].box.name.rpartition('/').last.to_s
            box_name = env[:machine].box.name.to_s
          else
            box_file = env[:machine].box.name.to_s
            box_name = box_file
          end

          cfg.org = cnx.get_organization_by_name(cfg.vdc_name)
          @logger.debug("cfg.org: #{cfg.org}")
          cfg.org_id = cnx.get_organization_id_by_name(cfg.vdc_name)
          @logger.debug("cfg.org_id: #{cfg.org_id}")

          cfg.vdc = cnx.get_vdc_by_name(cfg.org, cfg.vdc_name)
          cfg.vdc_id = cnx.get_vdc_id_by_name(cfg.org, cfg.vdc_name)

          cfg.catalog = cnx.get_catalog_by_name(cfg.org, cfg.catalog_name)
          cfg.catalog_id = cnx.get_catalog_id_by_name(cfg.org, cfg.catalog_name)

          if cfg.catalog_id.nil?
            env[:ui].warn(I18n.t(
                          'vagrant_vcloudair.catalog.nonexistant_catalog',
                          catalog_name: cfg.catalog_name))

            user_input = env[:ui].ask(
              I18n.t('vagrant_vcloudair.catalog.create_catalog_ask',
                     catalog_name: cfg.catalog_name) + ' '
            )

            if user_input.downcase == 'yes' || user_input.downcase == 'y'
              vcloud_create_catalog(env)
            else
              env[:ui].error(I18n.t(
                             'vagrant_vcloudair.catalog.catalog_not_created'))
              fail Errors::WontCreate, :item => 'Catalog'
            end
          end

          @logger.debug(
            "Getting catalog item with cfg.catalog_id: [#{cfg.catalog_id}] " +
            "and machine name [#{box_name}]"
          )
          cfg.catalog_item = cnx.get_catalog_item_by_name(
            cfg.catalog_id,
            box_name
          )

          @logger.debug("Catalog item is now #{cfg.catalog_item}")

          # This only works with Org Admin role or higher

          cfg.vdc_network_id = cfg.org[:networks][cfg.vdc_network_name]
          unless cfg.vdc_network_id
            # TODO: TEMP FIX: permissions issues at the Org Level for vApp
            # authors to "view" Org vDC Networks but they can see them at the
            # Organization vDC level (tsugliani)
            cfg.vdc_network_id = cfg.vdc[:networks][cfg.vdc_network_name]
            fail Errors::InvalidNetSpecification unless cfg.vdc_network_id
          end

          # Checking Catalog mandatory requirements
          if !cfg.catalog_id
            @logger.info("Catalog [#{cfg.catalog_name}] STILL does not exist!")
            fail Errors::ObjectNotFound,
                 :message => 'Catalog not found after creation'
          else
            @logger.info("Catalog [#{cfg.catalog_name}] exists")
          end

          if !cfg.catalog_item
            env[:ui].warn(I18n.t(
                          'vagrant_vcloudair.catalog.nonexistant_catalog_item',
                          catalog_item: box_name,
                          catalog_name: cfg.catalog_name))

            user_input = env[:ui].ask(
                         I18n.t('vagrant_vcloudair.catalog.upload_ask',
                                catalog_item: box_name,
                                catalog_name: cfg.catalog_name) + ' ')

            if user_input.downcase == 'yes' || user_input.downcase == 'y'
              env[:ui].info(I18n.t('vagrant_vcloudair.catalog.uploading',
                                   catalog_item: box_name))
              vcloud_upload_box(env)
            else
              env[:ui].error(
                I18n.t('vagrant_vcloudair.catalog.catalog_item_notavailable'))
              fail Errors::WontCreate, :item => 'Box'
            end

          else
            @logger.info(
              "Using catalog item [#{box_name}] " +
              "in Catalog [#{cfg.catalog_name}]..."
            )
          end

          # Test if Gateway Edge and its IP are correct
          if !cfg.vdc_edge_gateway.nil? && !cfg.vdc_edge_gateway_ip.nil?
            env[:ui].info(I18n.t('vagrant_vcloudair.edge.network_test'))
            # Test if Edge Gateway exists
            cnx.find_edge_gateway_id(cfg.vdc_edge_gateway, cfg.vdc_id)
            # Test if Edge Gateway IP exists
            cnx.find_edge_gateway_network(cfg.vdc_edge_gateway,
                                          cfg.vdc_id,
                                          cfg.vdc_edge_gateway_ip)
            # Test if Network is connected to Edge Gateway
            cnx.check_edge_gateway_network(cfg.vdc_edge_gateway,
                                           cfg.vdc_id,
                                           cfg.vdc_network_name)
          end
        end
      end
    end
  end
end
