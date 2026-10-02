class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]
  before_action :set_receiver, only: [:create]

  def index
    @users = User.where.not(id: current_user.id)

    @last_messages = {}

    latest_messages = Message
                        .where(
                          "sender_id = :user_id OR receiver_id = :user_id",
                          user_id: current_user.id
                        )
                        .select(
                          "DISTINCT ON (
          CASE
            WHEN sender_id = #{current_user.id}
            THEN receiver_id
            ELSE sender_id
          END
        ) messages.*"
                        )
                        .order(
                          Arel.sql(
                            "CASE
            WHEN sender_id = #{current_user.id}
            THEN receiver_id
            ELSE sender_id
          END,
          created_at DESC"
                          )
                        )

    latest_messages.each do |message|

      other_user_id =
        if message.sender_id == current_user.id
          message.receiver_id
        else
          message.sender_id
        end

      @last_messages[other_user_id] = message

    end

    @users = @users.sort_by do |user|
      @last_messages[user.id]&.created_at || Time.at(0)
    end.reverse
  end


  def show

    @messages = Message.where(
      sender: current_user,
      receiver: @user
    ).or(
      Message.where(
        sender: @user,
        receiver: current_user
      )
    ).order(:created_at)

    @message = Message.new

  end


  def create

    @message = current_user.sent_messages.build(message_params)

    @message.receiver = @user

    if @message.save

      redirect_to message_path(@user)

    else

      Rails.logger.debug @message.errors.full_messages

      redirect_to message_path(@user),
                  alert: @message.errors.full_messages.join(", ")

    end

  end


  private


  def set_user
    @user = User.find_by(id: params[:id])

    unless @user
      redirect_to messages_path,
                  alert: "User not found."
    end
  end


  def set_receiver
    @user = User.find_by(id: params[:message][:receiver_id])

    unless @user
      redirect_to messages_path,
                  alert: "User not found."
      return
    end

    if @user == current_user
      redirect_to messages_path,
                  alert: "You cannot message yourself."
    end
  end


  def message_params

    params.require(:message).permit(:content)

  end

end