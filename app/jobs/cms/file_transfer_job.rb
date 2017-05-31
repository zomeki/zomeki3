class Cms::FileTransferJob < ApplicationJob
  queue_as :cms_file_transfer
  queue_with_priority 20

  MAX_LOOP = 1000

  def perform
    loop_count = 0
    while Cms::FileTransfer.exists?
      if (loop_count += 1) > MAX_LOOP
        Cms::FileTransferJob.perform_later
        break
      end

      transfers = []
      Cms::FileTransfer.transaction do
        transfers = Cms::FileTransfer.queued_items.order(:priority, :id).limit(30).lock
        Cms::FileTransfer.where(id: transfers.map(&:id)).update_all(state: 'performing')
      end
      break if transfers.blank?

      grouped_transfers = transfers.group_by { |p| [p.priority, p.site_id] }.sort
      grouped_transfers.each do |(priority, site_id), items|
        ::Script.run("cms/file_transfers/exec", site_id: site_id, file_transfer_id: items.map(&:id))
      end
    end
  end
end
