class GpArticle::Hold < ApplicationRecord
  include Sys::Model::Base

  belongs_to :holdable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'
end
