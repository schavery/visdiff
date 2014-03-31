# ruby

=begin
dirRender.js passed to phantomjs binary will find all html files in
the current directory and render them into images.

It takes about a second per image, based on reddit as the example,
which is fairly complex markup.

Then, you can use imagemagick to generate the comparison.
First, you have to make the images the same dimensions, by
appending transparent pixels to the bottom of the shorter
image.
The command is:
	convert -background transparent \
	-extent $(identify <larger-image-file> | cut -d ' ' -f 3) \
	<smaller-image-file> <output-file-to-be-created>

To compare heights easily you can do to each:
	identify <input-file> | cut -d ' ' -f 3 | cut -d 'x' -f 2

We may be able to skip this by rendering the page at the highest height
we have seen the page at, and clipping extra white space at the bottom
of the diff image.

To compare the final results:
	compare <old-file> <new-file> <output-file-to-be-created>

=end

=begin
To save on storage complexity we want to inline ascii resources if possible.
1. have the markup.
1a. wget command
	wget --no-cookies --no-cache -pEHk -R .txt,.png,.jpg,.gif,.ico -e robots=off <url>
will save files in their directory structure reflected in local dir.

=end

require 'rubygems'
require 'nokogiri'
#require 'optparse'

# args1 = directory to open
# args2 = url name? may be removed
class ResourceInliner

	def initialize(dirname, urlname)
		@dirname = dirname
		@urlname = urlname
		@relpath = dirname + File::SEPARATOR + urlname + File::SEPARATOR
		@page = Nokogiri::HTML(open(@relpath + 'index.html'))
	end
	
	# we should count all the files inside the dirname to make sure
	# that we use them all
	def count
		Dir[File.join(@dirname, '**', '*')].count { |file| File.file?(file) }
	end

	def replace
		@tcount = count
		replaceLinkStyle
		replaceScriptSrc
		replaceIframe
		File.open(@dirname + File::SEPARATOR + @urlname + '.html', 'w') { |file| file.write(@page) }
		return @tcount
	end

	def replaceLinkStyle
		# 1. get css link rel stylesheet
		links = @page.css("link[rel='stylesheet']")
		prestyle = "<style type=\"text/css\">"
		poststyle = "</style>"

		links.each do |link|
			path = link['href']
			style = Nokogiri::HTML::DocumentFragment.parse(prestyle + File.read(@relpath + path) + poststyle)
			link.add_next_sibling(style)
			link.remove
			@tcount - 1
		end
	end

	def replaceScriptSrc
		scripts = @page.css("script[src]")

		scripts.each do |script|
			path = script['src']
			script.remove_attr('src') #undefined method
			script.contents(File.read(@relpath + path))
			@tcount - 1 
		end
	end

	def replaceIframe
		iframes = @page.css("iframe[src],iframe[srcdoc]")

		iframes.each do |iframe|
			path = iframe['src'] || iframe['srcdoc']
			iframe.remove_attr('src')
			iframe.remove_attr('srcdoc')
			iframe.contents(File.read(@relpath + path))
			@tcount - 1
		end
	end
end

r = ResourceInliner.new(ARGV[0],ARGV[1])
r.replace
