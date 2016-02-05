require 'ostruct'
require 'digest/md5'

module MiddlemanCasperHelpers
  def page_title
    if is_tag_page?
      title = current_resource.metadata[:locals]['tagname']
    elsif current_page.data.title
      title = current_page.data.title
    elsif is_blog_article?
      title = current_article.title
    end
    [title, blog_settings.name].compact.join(' // ')
  end

  def page_description
    if is_blog_article?
      body = strip_tags(current_article.body).gsub(/\s+/, ' ')
      truncate(body, length: 147)
    else
      blog_settings.description
    end
  end

  def page_class
    if is_blog_article? || current_page.data.layout == 'page'
      'post-template'
    elsif current_resource.metadata[:locals]['page_number'].to_i > 1
      'archive-template'
    else
      'home-template'
    end
  end

  def summary(article)
    summary_length = article.blog_options[:summary_length]
    strip_tags(article.summary(summary_length, ''))
  end

  def read_next_summary(article, words)
    body = strip_tags(article.body)
    truncate_words(body, length: words, omission: '')
  end

  def blog_author
    OpenStruct.new(casper[:author])
  end

  def blog_settings
    OpenStruct.new(casper[:blog])
  end

  def navigation
    casper[:navigation]
  end

  def is_tag_page?
    current_resource.metadata[:locals]['page_type'] == 'tag'
  end
  def tags?(article = current_article)
    article.tags.present?
  end
  def tags(article = current_article, separator = ', ')
    capture_haml do
      article.tags.each do |tag|
        haml_tag(:a, tag, href: tag_path(tag))
        haml_concat(separator) unless article.tags.last == tag
      end
    end.gsub("\n", '')
  end

  def current_article_url
    URI.join(blog_settings.url, current_article.url)
  end

  def cover(page = current_page)
    if (src = page.data.cover).present?
      { style: "background-image: url(#{image_path(src)})" }
    else
      { class: 'no-cover' }
    end
  end
  def cover?(page = current_page)
    page.data.cover.present?
  end

  def gravatar(size = 68)
    if blog_author.avatar_url.present?
      "#{blog_author.avatar_url}?size=#{size}"
    else
      md5 = Digest::MD5.hexdigest(blog_author.gravatar_email.downcase)
      "https://www.gravatar.com/avatar/#{md5}?size=#{size}"
    end
  end
  def gravatar?
    blog_author.avatar_url.present? ||
    blog_author.gravatar_email.present?
  end

  def twitter_url
    "https://twitter.com/share?text=#{ERB::Util.u current_article.title}" \
      "&url=#{ERB::Util.u current_article_url}"
  end
  def facebook_url
    "https://www.facebook.com/sharer/sharer.php?" \
      "u=#{ERB::Util.u current_article_url}"
  end
  def google_plus_url
    "https://plus.google.com/share?" \
      "url=#{ERB::Util.u current_article_url}"
  end
  def mail_url
    "mailto:?to=" \
      "&subject=#{ERB::Util.u current_article.title}" \
      "&body=#{ERB::Util.u "Check out this article. I think you'll find it of interest.\r\n\r\n" + current_article_url.to_s}"
  end

  def feed_path
    if is_tag_page?
      "#{current_page.url.to_s}feed.xml"
    else
      "#{blog.options.prefix.to_s}/feed.xml"
    end
  end
  def home_path
    "#{blog.options.prefix.to_s}/"
  end
  def author_path
    "#{blog.options.prefix.to_s}/author/#{blog_author.name.parameterize}/"
  end
  def author_email_link(span_class = nil)
    raw_email = blog_author.email.to_s.scan(/&#\d+;/).map{|c| c[2..-2].to_i}.pack('U*')

    # We emit the email address as HTML encoded ROT47 string
    email = raw_email.tr('!-~', 'P-~!-O').unpack('U*').map{ |code| "&##{code.to_s};"}.join

    if span_class
      writer = <<-JAVASCRIPT.tap { |s| s.gsub!(/^#{s.scan(/^[ \t]+(?=\S)/).min}/, '') }.html_safe
        document.addEventListener("DOMContentLoaded", function() {
          Array.prototype.forEach.call(document.getElementsByClassName("#{span_class}"), function(element){ element.innerHTML = link; });
        }, false);
      JAVASCRIPT
    else
      writer = 'document.write(link);'
    end

    script = <<-HTML.tap { |s| s.gsub!(/^#{s.scan(/^[ \t]+(?=\S)/).min}/, '') }
      <script type="text/javascript">
        (function() {
          function decodeHTMLEntities(str) {
            if(str && typeof str === 'string') {
              var e = document.createElement('div');
              e.innerHTML = str;
              str = e.innerHTML;
              e.remove();
            }
            return str;
          }
          function encodeHTMLEntities(str) {
            var buf = [];
            for (var i=str.length-1;i>=0;i--) {
              buf.unshift(['&#', str[i].charCodeAt(), ';'].join(''));
            }
            return buf.join('');
          };
          var str = encodeHTMLEntities(decodeHTMLEntities("#{email}").replace(/[!-~]/g,function(c){return String.fromCharCode(126>=(c=c.charCodeAt(0)+47)?c:c-94);}));
          var link = "<" + "a h" + "ref=\\\"mai" + "lto:" + str + "\\\">" + str + "</" + "a>";
          #{writer}
        })()
      </script>
    HTML
    script << '<noscript><em>(Please enable JavaScript to show the email address)</em></noscript>' unless span_class
    script.html_safe
  end

  def author_email_span(span_class)
    %{<span class="#{span_class}"><em>(Please enable JavaScript to show the email address)</em></span>}.html_safe
  end

  def og_type
    if is_blog_article?
      'article'
    else
      'website'
    end
  end

  def og_title
    if current_page.data.title
      current_page.data.title
    elsif is_tag_page?
      current_resource.metadata[:locals]['tagname']
    elsif is_blog_article?
      current_article.title
    else
      nil
    end
  end
end
