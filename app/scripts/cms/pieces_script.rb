class Cms::PiecesScript < PublicationScript
  def publish
    pieces = Cms::Piece.public_state.order(:name, :id)
    pieces.where!(site_id: ::Script.site.id) if ::Script.site
    pieces.where!(id: params[:target_piece_id]) if params.key?(:target_piece_id)

    pieces.each do |piece|
      publish_piece(piece)
    end
  end

  private

  def publish_piece(piece)
    script_klass = "::#{piece.model.sub('::', '::Piece::').pluralize}Script".safe_constantize
    if script_klass && script_klass.method_defined?(:publish)
      script_klass.new(params.merge(piece: piece)).publish
      file_transfer_callbacks(piece)
    end
  end

  def file_transfer_callbacks(piece)
    Cms::FileTransferCallbacks.new([:public_path, :public_smart_phone_path], recursive: true)
                              .after_publish_files(piece)
  end
end
