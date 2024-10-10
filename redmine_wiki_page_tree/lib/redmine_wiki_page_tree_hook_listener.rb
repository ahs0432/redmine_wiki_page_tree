class RedmineWikiPageTreeHookListener < Redmine::Hook::ViewListener
  include ActionView::Helpers::DateHelper
  include ActionView::Context

  # 사이드바 제작
  def view_layouts_base_sidebar(context = {})
    return unless context[:controller]
    params = context[:controller].params
    return unless params[:controller] == 'wiki'

    pages = load_pages(context[:request].params[:project_id])
    pages_by_parent_id = pages.group_by(&:parent_id)
    page_arr = check_my_page(pages, params[:id])

    content_tag(:div, class: 'page-tree') do
      concat content_tag(:h3, l(:page_tree), class: 'page-tree__title')
      concat render_page_hierarchy(pages_by_parent_id, nil, {:timestamp => true, :id => page_arr})
    end
  end

  # Asset 파일 불러오기
  def view_layouts_base_html_head(context)
    return unless context[:controller]
    params = context[:controller].params
    return unless params[:controller] == 'wiki'

    tags = []
    tags << stylesheet_link_tag('sidebar__page-tree', :plugin => 'redmine_wiki_page_tree')
    tags << javascript_include_tag('sidebar__page-tree', :plugin => 'redmine_wiki_page_tree')
    tags.join("\n")
  end

  private

  # 페이지 목록 불러와 Array 형태로 전달
  def load_pages(project_id)
    Project.find(project_id)
      .wiki
      .pages
      .with_updated_on
      .reorder("#{WikiPage.table_name}.title")
      .includes(:wiki => :project)
      .includes(:parent)
      .to_a
  end

  # 사이드바 제작
  def render_page_hierarchy(pages, node=nil, options={})
    content = ''
    if pages[node]
      content << "<ul class=\"page-tree__list\">\n"

      pages[node].each do |page|
        if pages[page.id]
          id_check = false
          options[:id].each do |page_id|
            if page_id == page.id.to_s
              id_check = true
            end
          end

          if id_check
            content << "<details open>"
          else
            content << "<details>"   
          end

          content << '<summary class="page-tree__node">'
          content << link_to_wiki(page, options)
          content << "</summary>\n"
          content << "<li>"
          content << "\n" + render_page_hierarchy(pages, page.id, options) if pages[page.id]
          content << "</li>\n"
          content << "</details>\n"
        else
          content << '<li class="page-tree__list__node--leaf">'
          content << link_to_wiki(page, options)
          content << "</li>\n"
        end
      end
      content << "</ul>\n"
    end
    content.html_safe
  end

  # 현재 페이지의 상위 페이지 리스팅 후 전달
  def check_my_page(pages, page_id)
    page_parent = Hash.new{}
    pages.each do |page|
      page_parent[page.id.to_s] = page.parent_id.to_s
    end

    page_arr = [page_id]
    if page_id 
      while true
        if page_parent[page_id] == ""
          break
        else
          page_arr.append(page_parent[page_id])
          page_id = page_parent[page_id]
        end
      end
    end

    page_arr
  end

  # 위치 관련 정보 전달
  def link_to_wiki(page, options)
    link_to(
      h(page.pretty_title),
      {:controller => 'wiki', :action => 'show', :project_id => page.project, :id => page.id, :version => nil},
      :title => (options[:timestamp] && page.updated_on ? l(:label_updated_time, distance_of_time_in_words(Time.now, page.updated_on)) : nil),
      :draggable => 'true',
      :data => { :wiki_page_id => page.id } )
  end
end
