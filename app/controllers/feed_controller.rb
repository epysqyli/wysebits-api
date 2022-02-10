class FeedController < ApplicationController
  include Pagy::Backend

  before_action :user, except: :guest_feed
  skip_before_action :authenticate_request, only: :guest_feed

  def guest_feed
    pagy, entries = pagy(TileEntry.all.order(updated_at: :desc)
    .includes({ book_tile: [{ book: %i[authors category] }, :user] }))

    resp = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                             { user: { only: %i[username id] } }] } })
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def user_feed
    pagy, entries = pagy(TileEntry.other_user_entries(user).order(updated_at: :desc)
    .includes({ book_tile: [{ book: %i[authors category] }, :user] }))

    resp = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                             { user: { only: %i[username id] } }] } })
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def categories_feed
    fav_categories = user.fav_categories.map(&:id)
    entries = TileEntry.where(book_tile_id: BookTile.where(book_id: Book.where(category_id: fav_categories)))
                       .includes({ book_tile: [{ book: %i[authors category] }, :user] })

    pagy, entries = pagy(entries.order(updated_at: :desc))

    entries = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                                { user: { only: %i[username id] } }] } })

    render json: { entries: entries, pagy: pagy_metadata(pagy) }
  end

  def following_feed
    following = user.following.map(&:id)
    entries = TileEntry.where(book_tile_id: BookTile.where(user_id: following))
                       .includes({ book_tile: [{ book: %i[authors category] }, :user] })

    pagy, entries = pagy(entries.order(updated_at: :desc))

    entries = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                                { user: { only: %i[username id] } }] } })

    render json: { entries: entries, pagy: pagy_metadata(pagy) }
  end

  private

  def user
    User.find params[:id]
  end
end
