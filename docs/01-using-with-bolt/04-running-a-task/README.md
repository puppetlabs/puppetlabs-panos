# Running a Task

We're all set to use bolt to connect to the firewall and run a task. The module comes with some tasks already available out of the box. For this tutorial we will use the `panos::apikey` task to generate an API key.

Type `bolt task run panos::apikey -n pan --debug` where -n represents the nodes, with `pan` the alias we set in the `inventory.yaml` file and `--debug` represents that we want to get debug level output. If everything is working as planned you should be able to see that the task runs successfully and returns an apikey as expected. Examining the debug output you will notice a few interesting things:

1. The task target is pan, which we know is a `remote target` as specified in our `inventory.yaml` and by default these tasks will run on the `localhost` transport.

2. The details from inventory.yaml are used by the task.

3. Additional parameters can be used, as outlined in the [bolt reference material](https://puppet.com/docs/bolt/latest/bolt_command_reference.html).

# Next steps

Now we'll apply a manifest.

[Applying a manifest](./../05-applying-a-manifest/README.md)