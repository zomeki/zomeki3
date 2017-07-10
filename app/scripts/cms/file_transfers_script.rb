class Cms::FileTransfersScript < ParametersScript
  def exec
    if params[:file_transfer_id].present?
      transfers = Cms::FileTransfer.where(id: params[:file_transfer_id])
                                   .order(priority: :asc, id: :asc)
      transfers = transfers.where(site_id: ::Script.site.id) if ::Script.site
    else
      path = if ::Script.site
               "sites/#{format('%04d', ::Script.site.id)}/"
             else
               "sites/"
             end
      transfers = [Cms::FileTransfer.new(path: path, recursive: true)]
    end

    ::Script.total transfers.size

    transfers.each do |transfer|
      ::Script.progress(transfer) do
        rsync(transfer.path, recursive: transfer.recursive) if ::File.exists?(transfer.path)
        transfer.destroy
      end
    end
  end

  private

  def rsync(path, options = {})
    require "open3"

    commands = rsync_commands(path, options)
    commands.each do |command|
      ::Script.log command
      out, error = Open3.capture3(command)
      ::Script.log out if out.present?
      ::Script.error error if error.present?
    end
  end

  def rsync_commands(path, options)
    conf = Util::Config.load(:rsync).with_indifferent_access

    src_path = path
    src_path += '/' if src_path[-1] != '/'

    Array(conf[:dests]).map do |dest|
      dest[:path] += '/' if dest[:path][-1] != '/'
      opts = [conf[:opts], dest[:opts]].select(&:present?).join(' ')
      com = "#{conf[:bin]} #{opts} --relative #{src_path} #{dest[:path]}"
      com << (options[:recursive] ? " --recursive" : " --dirs")
      com
    end
  end
end
