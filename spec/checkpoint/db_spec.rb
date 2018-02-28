# frozen_string_literal: true

require 'sequel_helper'

# This is a rather odd spec file because its purpose is to test that the config
# handling/startup is working as expected. The rest of the tests that depend on
# the database just require 'sequel_helper', which handles the setup. This
# group has to do a lot of fiddling to both verify the behavior and cooperate
# with the other tests.

RSpec.xdescribe Checkpoint::DB do
  before(:each) do
    @db = Checkpoint::DB.db
  end

  after(:each) do
    Checkpoint::DB.initialize!(db: @db)
  end

  describe '#initialize!' do
    it 'connects with a URL string' do
      Checkpoint::DB.initialize!(url: 'mock:///')
      expect(Checkpoint::DB.db.adapter_scheme).to eq :mock
    end

    it 'connects with an options hash' do
      Checkpoint::DB.initialize!(opts: { adapter: 'sqlite' })
      expect(Checkpoint::DB.db.adapter_scheme).to eq :sqlite
    end

    it 'returns the database' do
      db = Checkpoint::DB.initialize!(url: 'mock:///')
      expect(db).to eq Checkpoint::DB.db
    end

    it 'can use an existing connection' do
      db = Sequel.sqlite
      Checkpoint::DB.initialize!(db: db)
      expect(db).to eq Checkpoint::DB.db
    end

    it 'raises a connection error on a bad URL' do
      expect { Checkpoint::DB.initialize!(url: 'badurl') }.to raise_error StandardError
    end

    describe 'migration check' do
      def unload_permit
        $LOADED_FEATURES.delete_if { |file| file.include?('/lib/checkpoint/db/permit.rb') }
        Checkpoint::DB.send(:remove_const, :Permit)
      end

      before do
        @db = Sequel::Model.db
      end

      it 'raises an error if migrations have not been run' do
        expect do
          db = Sequel.sqlite
          Sequel::Model.db = db
          unload_permit
          Checkpoint::DB.initialize!(db: db)
        end.to raise_error Checkpoint::DB::DatabaseError
      end

      after do
        Sequel::Model.db = @db
        unload_permit
        Checkpoint::DB.initialize!(db: @db)
      end
    end
  end
end
