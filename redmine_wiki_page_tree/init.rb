# 비정상 작동으로 인한 require_dependency 비활성화
#require_dependency 'redmine_wiki_page_tree_hook_listener'

Redmine::Plugin.register :redmine_wiki_page_tree do
  name 'Redmine Wiki Page Tree Plugin'
  author 'Chance'
  description 'Redmine plugin to show the page tree view at the sidebar.'
  version '0.0.3'
  url 'https://github.com/ahs0432/redmine_wiki_page_tree'
  author_url 'https://github.com/ahs0432'
end
