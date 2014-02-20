module Essential
  module Presenter
    class Nav < Essential::Presenter::Base
      presents :nav

      attr_accessor :params, :current_user, :assigns

      def initialize(object, template)
        @active_class = 'active'
        self.assigns = template.assigns #strangly this is how we get access to instances from the controller
        self.params = template.params
        self.current_user = template.current_user
        super(object, template)
      end

      def items
        items = Essential::Nav.items self

        if items
          items.map! { |item| init_item item}
          items.compact # remove nil elements
        else
          []
        end
      end

      private

      def init_item item
        return if(item.has_key?(:permission) && !item[:permission])
        item['is_active?'] = check_if_active item
        item = OpenStruct.new item
        if item.respond_to? :children
          item.children.map! do |child_item|
            next if(child_item.has_key?(:permission) && !child_item[:permission])
            child_item[:parent] = item
            init_item child_item
          end
        end
        item
      end

      def check_if_active item
        if @template.current_page? item[:path]
          item[:parent][:is_active?] = @active_class if item[:parent]
          if regex = item[:highlights_on]
            if @template.request.fullpath.match regex
              @active_class
            else
              false
            end
          else
            @active_class
          end
        else
          false
        end
      end
    end
  end
end
