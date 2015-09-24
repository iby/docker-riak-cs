#!/usr/bin/env bash

# Patch the configuration files according to the Riak CS configuration guide.
# http://docs.basho.com/riakcs/latest/cookbooks/configuration/

function riak_patch_config(){
    echo -n 'Updating Riak configuration…'
    local advancedConfigPath='/etc/riak/advanced.config'

    # Expose the necessary Riak CS modules to Riak and instruct Riak to use the custom backend provided by Riak CS. Set
    # the `allow_mult` parameter to `true` to enable Riak to create siblings, which is necessary for Riak CS to function.

    cat <<-EOL > $advancedConfigPath
		[
		    {riak_kv, [
		        %% Storage_backend specifies the Erlang module defining the storage mechanism that will be used on this node.
		        {add_paths, ["$(ls -d /usr/lib/riak-cs/lib/riak_cs-*)/ebin"]},
		        {storage_backend, riak_cs_kv_multi_backend},
		        {multi_backend_prefix_list, [{<<"0b:">>, be_blocks}]},
		        {multi_backend_default, be_default},
		        {multi_backend, [
		            {be_default, riak_kv_eleveldb_backend, [
		                {max_open_files, 30},
		                {data_root, "/var/lib/riak/leveldb"}
		            ]},
		            {be_blocks, riak_kv_bitcask_backend, [
		                {data_root, "/var/lib/riak/bitcask"}
		            ]}
		        ]}
		    ]},
		    {riak_core, [
		        {default_bucket_props, [{allow_mult, true}]}
		    ]}
		].
	EOL

	echo ' OK!'
}

function riak_cs_patch_config(){
    echo -n 'Updating Riak-CS configuration…'
    local advancedConfigPath='/etc/riak-cs/advanced.config'

    # Must create an admin user to use Riak CS, also create commented placeholders for key and secret, we'll update them
    # later.

    # Fixme: ssl currently doesn't work, check back on http://git.io/RxYPrw and update SSL config and user creation URL…

    cat <<-EOL > $advancedConfigPath
		[
		    {riak_cs, [
		        {anonymous_user_creation, true},
		        %%{admin_key, null},
		        %%{admin_secret, null},
		        {cs_root_host, "s3.amazonaws.dev"},
		        {fold_objects_for_list_keys, true},
		        {listener, {"0.0.0.0", 8080}}
		    ]}
		].
	EOL

    echo ' OK!'
}

function stanchion_patch_config(){
    echo -n 'Updating Stanchion configuration…'
    local advancedConfigPath='/etc/stanchion/advanced.config'

    cat <<-EOL > $advancedConfigPath
		[
		    {stanchion, [
		        %%{admin_key, null},
		        %%{admin_secret, null}
		    ]}
		].
	EOL

	echo ' OK!'
}

riak_patch_config
riak_cs_patch_config
stanchion_patch_config

# Set default service parameters.

echo "ulimit -n 65536" >> /etc/default/riak