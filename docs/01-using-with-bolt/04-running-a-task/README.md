# Running a Task

We're all set to use bolt to connect to the firewall and run a task. The module comes with some tasks already available out of the box. For this tutorial we will use the `panos::apikey` task to generate an API key.

Type `bolt task run panos::apikey -n pan --debug` where -n represents the nodes, with `pan` the alias we set in the `inventory.yaml` file and `--debug` represents that we want to get debug level output. If everything is working as planned you should be able to see that the task runs successfully and returns an apikey as expected. Examining the debug output you will notice a few interesting things:

1. The task target is localhost, meaning it ran on your localhost machine. It is possible for bolt to execute on [remote targets](https://puppet.com/docs/bolt/latest/bolt_configuration_options.html#remote-transport-configuration-options) for infrastructure that is located on a different network segment to your localhost.

2. The details from inventory.yaml are used by the task.

3. Additional parameters can be used, as outlined in the [bolt reference material](https://puppet.com/docs/bolt/latest/bolt_command_reference.html).

# Next steps

Now we'll execute a manifest.

[Executing a manifest](./../05-execute-a-manifest/README.md)