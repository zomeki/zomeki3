class Cms::FileTransfersScript < Cms::Script::Base
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
        if ::File.exists?(transfer.path)
          out, error = rsync(transfer.path, recursive: transfer.recursive)
          ::Script.log out if out.present?
          raise error if error.present?
        end
        transfer.destroy
      end
    end
  end

  private

  def rsync(path, options = {})
    require "open3"
    com = rsync_command(path, options)
    ::Script.log com
    Open3.capture3(com)
  end

  def rsync_command(path, options)
    conf = Util::Config.load(:rsync).with_indifferent_access

    src_path = path
    src_path += '/' if src_path[-1] != '/'
    dest_path = conf[:dest_path]
    dest_path += '/' if dest_path[-1] != '/'

    com = "#{conf[:bin]} #{conf[:opts]} --relative #{src_path} #{dest_path}"
    com << (options[:recursive] ? " --recursive" : " --dirs")
    com
  end
end
