require 'test/unit'
require 'active_record/fixtures'

module PluginAWeek #:nodoc:
  # Fixture references are a way of easily accessing attributes of other
  # fixtures in order to keep your data DRY.  This is primarily useful with
  # referencing foreign key ids from other tables.  For example, rather than
  # hard-coding an id in multiple files, fixture references will allow you to
  # reference that fixture like you normally would in a unit test case.
  # 
  # == Defining fixtures to reference
  # 
  # In order to begin referencing fixture records in other files, you must first
  # define what fixtures you're going to use like so:
  # 
  # departments.yml:
  #   <% fixtures :employees %>
  # 
  # You can define multiple fixtures as well:
  # 
  #   <% fixtures :employees, :companies %>
  # 
  # == Reference individual fixtures
  # 
  # Once invoking the +fixtures+ method, you can now begin referencing those fixtures:
  # 
  # departments.yml:
  #   <% fixtures :employees %>
  #   
  #   packaging:
  #     id: 1
  #     name: Packaging
  #     manager_id: <%= employees(:manager) %>
  # 
  # As can be seen, <tt>fixtures :employees</tt> creates an +employees+ method.
  # By calling that method and passing in the name of the fixture, you can access
  # all of the attributes defined for that fixture.
  # 
  # == Accessing other fixture attributes
  # 
  # By default, the id attribute is accessed.  However, if we wanted to access
  # the name instead of the id, we would do the following:
  # 
  #   packaging:
  #     id: 1
  #     name: Packaging
  #     manager_name: <%= employees(:manager, 'name') %>
  # 
  # == Local references
  # 
  # In addition to referencing fixtures in external files, you can also
  # reference fixtures in the same file.  For example,
  # 
  # companies.yml:
  #   <% id = 0; fixtures :companies %>
  #   
  #   time_warner:
  #     id: <%= id += 1 %>
  #     name: Time Warner
  #     
  #   cnn:
  #     id: <%= id += 1 %>
  #     name: CNN
  #     parent_company_id: <%= companies(:time_warner) %>
  # 
  # *Note* that you must define any individual fixtures before referencing them.
  # For example, reversing the locations of time_warner and cnn would cause the
  # fixture to fail.
  # 
  # == Circular references
  # 
  # This plugin is capable of handling circular references between external
  # fixture files but *not* within the same file (i.e. between local references).
  module FixtureReferences
    def self.included(base) #:nodoc:
      base.class_eval do
        cattr_accessor :fixture_path
        
        cattr_accessor :all_partially_loaded_fixtures
        self.all_partially_loaded_fixtures = {}
        
        extend PluginAWeek::FixtureReferences::ClassMethods
        include PluginAWeek::FixtureReferences::InstanceMethods
      end
    end
    
    module ClassMethods #:nodoc:
      def self.extended(base)
        class << base
          alias_method_chain :create_fixtures, :references
        end
      end
      
      def create_fixtures_with_references(fixtures_directory, *args)
        self.fixture_path = fixtures_directory
        create_fixtures_without_references(fixtures_directory, *args)
      end
    end
    
    module InstanceMethods
      def self.included(base) #:nodoc:
        base.class_eval do
          alias_method :erb_render, :erb_render_with_fixture_references
        end
      end
      
      # Defines what fixtures will be referenced.
      def fixtures(*table_names)
        table_names.flatten.each do |table_name|
          table_name = table_name.to_s
          
          if all_loaded_fixtures[table_name].nil?
            all_loaded_fixtures[table_name] = false # Keep track that we're loading this fixture
            all_loaded_fixtures[table_name] = Fixtures.new(@connection, File.split(table_name).last, nil, File.join(self.fixture_path, table_name))
          elsif all_loaded_fixtures[table_name] == false && all_partially_loaded_fixtures[table_name].nil? 
            all_partially_loaded_fixtures[table_name] = false # Keep track that we're partially loading this fixture
            all_partially_loaded_fixtures[table_name] = Fixtures.new(@connection, File.split(table_name).last, nil, File.join(self.fixture_path, table_name))
          end
          
          instance_eval <<-end_eval
            def #{table_name}(fixture_name, attribute = 'id')
              fixtures = all_loaded_fixtures[#{table_name.inspect}] || all_partially_loaded_fixtures[#{table_name.inspect}]
              
              # When this is a bidirectional reference and no fixtures have been
              # completely loaded yet, return nil for the attribute value
              if fixtures.is_a?(Fixtures)
                if fixture = fixtures[fixture_name.to_s]
                  fixture[attribute.to_s] || raise(StandardError, "No attribute with name '\#{attribute}' found for fixture '\#{fixture_name}' in table '#{table_name}'")
                else
                  raise StandardError, "No fixture with name '\#{fixture_name}' found for table '#{table_name}'"
                end
              else
                nil
              end
            end
          end_eval
        end
      end
      
      def erb_render_with_fixture_references(fixture_content) #:nodoc:
        ERB.new(fixture_content).result(binding)
      end
    end
  end
end

Fixtures.class_eval do
  include PluginAWeek::FixtureReferences
end
