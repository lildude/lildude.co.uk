require "rubygems"
require "bundler/setup"
require "stringex"
require "yaml"
require "html-proofer"

## -- Misc Configs -- ##
public_dir      = "_site"     # compiled site directory
stash_dir       = "_stash"    # directory to stash posts for speedy generation
drafts_dir      = "_drafts"   # directory for draft files
posts_dir       = "_posts"    # directory for blog files
new_post_ext    = "md"        # default new post file extension when using the new_post task
editor          = "atom"      # default editor to use to open and edit your new posts

## -- Site -- ##  This is so I can easily share the same Rakefile between all my sites.
config = YAML.load_file('_config.yml')
$site = config["url"].match(/(?<=https:\/\/)[a-z][^.]*/)[0]

## -- Tasks -- ##

# usage rake new_post[my-new-post] or rake new_post['my new post'] or rake new_post (defaults to "new-post")
desc "Begin a new post in #{posts_dir}"
task :new, [:title, :bowfmt, :eowfmt] do |t, args|
  args.with_defaults(:bowfmt => nil, :eowfmt => nil)
  title = args.title || get_stdin("Enter a title for your post: ")
  filename = "#{drafts_dir}/#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new draft post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    post.puts "tags:"
    # Add week in review specific tags as these are the same
    if title.include? "Week in Review:"
      post.puts "- training\n- review"
    else
      post.puts "- "
    end
    post.puts "type: post"
    post.puts "published: true"
    post.puts "---"
    # Add img to top of week in review posts
    if title.include? "Week in Review:"
      post.puts "\n![Week in Review: #{args.bowfmt} - #{args.eowfmt}](/assets/week-in-review-#{args.bowfmt.gsub(/[\s']/,'')}-#{args.eowfmt.gsub(/[\s']/,'')}.png){:height=\"240\" width=\"840\" class=\"center\"}"
    end
  end
  system "#{editor} #{filename}"
end

desc "New Week in Review post."
task :wir do
  now = DateTime.now
  eow = now - now.wday
  bow = eow - 6
  bowfmt = (bow.mon == eow.mon) ? bow.strftime('%-d') : bow.strftime('%-d %b')
  eowfmt = eow.strftime("%-d %b '%y")
  Rake::Task["new"].invoke("Week in Review: #{bowfmt} - #{eow.strftime("%-d %b '%y")}", bowfmt, eowfmt)
end

desc "Publish a draft post in #{drafts_dir}"
task :publish, :draft_file do |t, args|
  draft_post = args.draft_file || (system("ls -lr #{drafts_dir}") && get_stdin("\nEnter draft post filename: "))
  filename = "#{drafts_dir}/#{draft_post}"
  puts "Publishing #{draft_post}".yellow
  # Update the date to the publish date
  post = File.read(filename)
  File.write(filename, post.sub!(/^date:.*?$/, "date: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"))
  # Get post title for nice commit message.
  f = YAML.load_file(filename)
  post_title = f["title"]
  system("git mv #{filename} #{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{draft_post}")
  system("git commit -am \"Publishing: #{post_title} \"")
end

# Requires ImageOptim and ImageOptim-CLI
desc "Minify assets"
task :minify do
  file_exts = [".gif", ".jpg", ".jpeg", ".png", ".JPG"]
  images = ''
  # Grab time of last compress run
  last_run = File.exist?("assets/.last-compressed") ? Time.at(IO::readlines("assets/.last-compressed")[1].strip.to_i) : Time.new(1990)
  Dir.glob("assets/**/*.*") do |file|
    case File.extname(file)
    when *file_exts
      if File.stat(file).mtime > last_run
        images << "#{file}\n"
      end
    end
  end

  unless images.blank?
    puts "\n## Compressing new images".yellow
    puts images
    ok_failed(system("echo \"#{images}\" | ~/bin/ImageOptim-CLI-1.11.6/bin/imageoptim --image-alpha --quit"))
    # Write last compressed date to file.
    t = Time.now
    File.open("assets/.last-compressed", "w+") { |f| f.puts "# #{t.to_s}\n#{t.to_i}" }
    ok_failed(system("git add assets"))
    ok_failed(system("git commit -m \"Optimise images\" 1>/dev/null"))
  end
end

desc "Deploy master to Digital Ocean using rsync and copy _site/ to gh-pages branch and push to GitHub repo."
task :deploy do
  unless Dir.glob("#{stash_dir}/*.*").empty?
    puts "ERROR: #{stash_dir} is not empty. Unstash and try again".red
    exit
  end

  # This only produces output of there are files to minify.
  Rake::Task["minify"].execute

  puts "\n## Deleting gh-pages branch".yellow
  ok_failed(system("git branch -D gh-pages 1>/dev/null"))

  puts "\n## Creating new gh-pages branch and switching to it".yellow
  ok_failed(system("git checkout -b gh-pages 1>/dev/null"))

  puts "\n## Generating _site content".yellow
  ok_failed(system("bundle exec jekyll build 1> /dev/null"))

  puts "\n## Removing _site from .gitignore".yellow
  ok_failed(system("sed -i '' -e 's/_site//g' .gitignore"))

  puts "\n## Force GitHub Pages Jekyll processing bypass with .nojekyll".yellow
  ok_failed(system("touch _site/.nojekyll"))

  puts "\## Deploying to Digital Ocean".yellow
  ok_failed(system("/usr/local/bin/rsync --compress --recursive --checksum --delete --itemize-changes --iconv=utf-8-mac,utf-8 _site/ do1:www/static-sites/#{$site}/")) # Requires rsync 3 on the Mac.

  puts "\n## Adding _site".yellow
  ok_failed(system("git add .gitignore _site assets/.last-compressed"))

  puts "\n## Committing site".yellow
  message = "Built site at #{Time.now.utc}"
  ok_failed(system("git commit -m \"#{message}\" 1>/dev/null"))

  puts "\n## Forcing the _site subdirectory to be project root".yellow
  ok_failed(system("git filter-branch --subdirectory-filter _site/ -f 1>/dev/null"))

  puts "\n## Switching back to master branch".yellow
  ok_failed(system("git checkout master 1>/dev/null"))

  puts "\n## Pushing all branches to origin".yellow
  ok_failed(system("git push origin master gh-pages --force 1>/dev/null"))
end

desc "Test site"
task :test do
  sh "JEKYLL_ENV=test bundle exec jekyll build"
  HTMLProofer.check_directory("./_site", {
    :assume_extension => true,
    :check_favicon => true,
    :check_html => true,
    :disable_external => true,
    :cache => { :timeframe => '2w' },
    :empty_alt_ignore => true,
    :verbose => true,
    :href_swap => {%r{(?<!\/)^\/{1}(?!\/)} => "https://#{$site}.co.uk/"}, # Matches /foo/doo but not //foo/doo - useful for protocol-less links.
    :typhoeus => { :verbose => true, :followlocation => true },
    :parallel => { :in_processes => 3}}).run
end

desc "Generate and display locally"
task :server do
  system("JEKYLL_ENV=local bundle exec jekyll serve --profile --watch --drafts --baseurl= --limit_posts=20")
end


## -- Misc Functions -- ##
def ok_failed(condition)
  if (condition)
    puts "=> OK".green
  else
    puts "=> FAILED".red
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end
