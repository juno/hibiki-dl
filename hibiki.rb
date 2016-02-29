require 'english'
require 'shellwords'
require 'logger'
require 'mechanize'

class Hibiki
  FFMPEG = 'ffmpeg'.freeze

  # Constructor.
  #
  # Returns nothing.
  def initialize(logger: Logger.new($stdout))
    @logger = logger
    @mechanize = Mechanize.new
    @mechanize.user_agent_alias = 'Windows Chrome'
  end

  # access_id - A String.
  # output_dir - A String.
  #
  # Returns nothing.
  def download(access_id: nil, output_dir: '.')
    @logger.info "Start downloading. access_id=#{access_id} output_dir: #{output_dir}"

    infos = get_infos(access_id)
    url = get_m3u8_url(infos['episode']['video']['id'])
    unless download_hls(access_id, url)
      @logger.error { "Download failed. url=#{url}" }
      return
    end

    @logger.info 'Download done.'
  end

  private

  # access_id - A String.
  #
  # Returns Hash.
  def get_infos(access_id)
    res = get_api("https://vcms-api.hibiki-radio.jp/api/v1/programs/#{access_id}")
    JSON.parse(res.body)
  end

  # video_id - A String.
  #
  # Returns URL String.
  def get_m3u8_url(video_id)
    res = get_api("https://vcms-api.hibiki-radio.jp/api/v1/videos/play_check?video_id=#{video_id}")
    play_infos = JSON.parse(res.body)
    play_infos['playlist_url']
  end

  def download_hls(access_id, m3u8_url)
    file_path = "#{access_id}.mp4"
    arg = "\
      -loglevel error \
      -y \
      -i #{Shellwords.escape(m3u8_url)} \
      -vcodec copy -acodec copy -bsf:a aac_adtstoasc \
      #{Shellwords.escape(file_path)}"

    full = "#{FFMPEG} #{arg}"
    exit_status, output = shell_exec(full)
    unless exit_status.success?
      @logger.info { "exit_status=#{exit_status} output=#{output}" }
      return false
    end

    true
  end

  # url - A URL String.
  #
  # Returns Mechanize::File
  def get_api(url)
    @mechanize.get(
      url,
      [],
      'http://hibiki-radio.jp/',
      'X-Requested-With' => 'XMLHttpRequest',
      'Origin' => 'http://hibiki-radio.jp'
    )
  end

  def shell_exec(command)
    output = `#{command}`
    exit_status = $CHILD_STATUS
    [exit_status, output]
  end
end

if __FILE__ == $0
  if ARGV[0].nil?
    puts "Usage: #{$0} <access_id> [output_dir]"
    exit
  end
  Hibiki.new.download(access_id: ARGV[0], output_dir: ARGV[1] || '.')
end
