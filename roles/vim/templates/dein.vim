" Dein
" {{ ansible_managed }}

if &compatible
    set nocompatible
endif

set runtimepath^={{ vim_plugin_manager_path }}

call dein#begin('{{ vim_plugin_path }}')

{% for plugin in vim_plugins %}
call dein#add('{{ plugin.repo | default(plugin) }}'{{ ', ' + (plugin.opts | to_json | regex_replace('"', '\'') | regex_replace('\'(function)(.*)\'(,|})', '\\1\\2\\3')) if plugin.opts is defined else '' }})
{% endfor %}

call dein#end()

filetype plugin indent on

if dein#check_install()"
  call dein#install()"
endif
