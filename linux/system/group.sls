{%- from "linux/map.jinja" import system with context %}
{%- if system.enabled %}

{%- macro set_p(paramname, dictvar) -%}
  {%- if paramname in dictvar -%}
- {{ paramname }}: {{ dictvar[paramname] }}
  {%- endif -%}
{%- endmacro -%}

{%- for group_name, group in system.group.iteritems() %}

{%- if group.enabled %}

{%- set requires = [] %}
{%- for user in group.get('addusers', []) %}
  {%- if user in system.get('user', {}).keys() %}
    {%- do requires.append({'user': 'system_user_'+user}) %}
  {%- endif %}
{%- endfor %}

system_group_{{ group_name }}:
  group.present:
  - name: {{ group.get('name', group_name) }}
  {%- if group.system is defined and group.system %}
  - system: True
  {%- endif %}
  {%- if group.gid is defined and group.gid %}
  - gid: {{ group.gid }}
  {%- endif %}
  - require: {{ requires|yaml }}
{{ set_p('addusers', group)|indent(2, True) }}
{{ set_p('delusers', group)|indent(2, True) }}

{%- else %}

system_group_{{ group_name }}:
  group.absent:
  - name: {{ group.name }}

{%- endif %}

{%- endfor %}

{%- endif %}

