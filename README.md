# BlogQueue
Queue up blog posts to release on your own schedule, all hosted in GitHub.

This action is meant to add a post file into your posts directory in your blog repo. In many cases, simply adding the new blog file will trigger CI to redeploy your website with the new post.

In your repository workflow file, you provide the path to your blog queue directory (where the pending blog files are stored), and the directory your blog uses for live posts. Here's an example workflow that will run on a weekly schedule.

```yaml
name: Blog Queue Workflow
#Run every Monday at 10:00AM.
on:
  schedule:
  - cron: '0 10 * * 1'
  workflow_dispatch:

jobs:
  update-sponsors-section:
    name: Publish blog post from queue.
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: matthewjdegarmo/blogqueue@latest
        with:
          queue_path: ./.blogqueue
          destination_path: ./_posts/
```

This action is pretty basic, and doesn't support any type of custom ordering of which blog to post next. This action uses the default order that the PowerShell `Get-ChildItem` command gives you, and uses the first one in the list.
