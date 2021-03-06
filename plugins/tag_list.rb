# Tag Cloud for Octopress, modified by pf_miles, for use with utf-8 encoded blogs(all regexp added 'u' option).
# =======================
# 
# Description:
# ------------
# Easy output tag cloud and tag list.
# 
# Syntax:
# -------
#     {% tag_cloud [counter:true] %}
#     {% tag_list [counter:true] %}
# 
# Example:
# --------
# In some template files, you can add the following markups.
# 
# ### source/_includes/custom/asides/tag_cloud.html ###
# 
#     <section>
#       <h1>Tag Cloud</h1>
#         <span id="tag-cloud">{% tag_cloud %}</span>
#     </section>
# 
# ### source/_includes/custom/asides/tag_list.html ###
# 
#     <section>
#       <h1>Categories</h1>
#         <ul id="tag-list">{% tag_list counter:true %}</ul>
#     </section>
# 
# Notes:
# ------
# Be sure to insert above template files into `default_asides` array in `_config.yml`.
# And also you can define styles for 'tag-cloud' or 'tag-list' in a `.scss` file.
# (ex: `sass/custom/_styles.scss`)
# 
# Licence:
# --------
# Distributed under the [MIT License][MIT].
# 
# [MIT]: http://www.opensource.org/licenses/mit-license.php
# 
module Jekyll

  class TagCloud < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @opts = {}
      @opts['limit'] = 10
      if markup.strip =~ /\s*counter:(\w+)/iu
        @opts['counter'] = ($1 == 'true')
        markup = markup.strip.sub(/counter:\w+/iu,'')
      end
      if markup.strip =~ /\s*limit:(\d+)/iu
        @opts['limit'] = $1.to_i
        markup = markup.strip.sub(/limit:\d+/iu,'')
      end
      if markup.strip =~ /\s*class:([\w_-]+)/iu
        @opts['class'] = $1
        markup = markup.strip.sub(/class:[\w_-]+/iu,'')
      end
      super
    end

    def render(context)
      lists = {}
      max, min = 1, 1
      config = context.registers[:site].config
      tag_dir = config['root'] + config['tag_dir'] + '/'
      tags = context.registers[:site].tags
      tags.keys.sort_by{ |str| str.downcase }.each do |tag|
        count = tags[tag].count
        lists[tag] = count
        max = count if count > max
      end

      html = ''
      lists.sort_by{ |tag, counter| counter }.reverse.take(@opts['limit']).each do | tag, counter |
        url = tag_dir + tag.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase
        style = "font-size: #{100 + (60 * Float(counter)/max)}%"

        if @opts['class'].length > 0
          html << "<li><a href='#{url}' class='#{@opts['class']}' style='#{style}'>"
        else 
          html << "<li><a href='#{url}' style='#{style}'>"
        end
        if @opts['icon']
          html << "<i class='icon-#{name}'></i> "
        end
        html << "#{tag}"
        if @opts['counter']
          html << " (#{tags[tag].count})"
        end
        html << "</a></li>"
      end
      html
    end
  end

  class TagList < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      @opts = {}
      if markup.strip =~ /\s*counter:(\w+)/iu
        @opts['counter'] = ($1 == 'true')
        markup = markup.strip.sub(/counter:\w+/iu,'')
      end
      if markup.strip =~ /\s*icon:(\w+)/iu
        @opts['icon'] = ($1 == 'true')
        markup = markup.strip.sub(/icon:\w+/iu,'')
      end
      if markup.strip =~ /\s*limit:(\d+)/iu
        @opts['limit'] = $1
        markup = markup.strip.sub(/limit:\d+/iu,'')
      end
      if markup.strip =~ /\s*class:([\w_-]+)/iu
        @opts['class'] = $1
        markup = markup.strip.sub(/class:[\w_-]+/iu,'')
      end
      super
    end

    def render(context)
      html = ""
      config = context.registers[:site].config
      tag_dir = config['root'] + config['tag_dir'] + '/'
      tags = context.registers[:site].tags
      tags.keys.sort_by{ |str| str.downcase }.each do |tag|
        name = tag.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').downcase
        url = tag_dir + name
        if @opts['class'].length > 0
          html << "<li><a href='#{url}' class='#{@opts['class']}'>"
        else 
          html << "<li><a href='#{url}'>"
        end
        if @opts['icon']
          html << "<i class='icon-#{name}'></i> "
        end
        html << "#{tag}"
        if @opts['counter']
          html << " (#{tags[tag].count})"
        end
        html << "</a></li>"
      end
      html
    end
  end

end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloud)
Liquid::Template.register_tag('tag_list', Jekyll::TagList)
