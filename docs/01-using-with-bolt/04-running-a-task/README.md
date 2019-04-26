# Run a Bolt Task

Use Bolt to connect to the firewall and run a task. The module comes with some tasks already available.

1. Use the `panos::apikey` task to generate an API key. Run:

`bolt task run panos::apikey -n pan --debug`. 

Note that `-n` represents the nodes, `pan` is the alias you set in the `inventory.yaml` file and `--debug` provides a debug level output. If everything works, you will the task run successfully and return an api key. 

Notice the following in the debug output:

* Bolt used the details you added to the `inventory.yaml` file. For example, the task target is `pan`, which is the `remote target` you specified in the `inventory.yaml`. By default these tasks run on the `localhost` transport.
* You can add additional parameters. For more information, see [Bolt reference material](https://puppet.com/docs/bolt/latest/bolt_command_reference.html).

# Next steps

Now you will apply a manifest.

[Applying a manifest](./../05-applying-a-manifest/README.md)
