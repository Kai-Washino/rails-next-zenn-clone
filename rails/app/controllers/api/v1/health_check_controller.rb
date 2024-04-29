# frozen_string_literal: true

module Api
  module V1
    class HealthCheckController < ApplicationController
      def index
        #   binding.pry
        render json: { message: 'Success Health Check!!' }, status: :ok
      end
    end
  end
end
