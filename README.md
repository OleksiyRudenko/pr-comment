# PR Comment Action

A GitHub action that will comment on the relevant open PR with a file contents when a commit is pushed.

## Usage

- Requires the `GITHUB_TOKEN` secret.
- Requires the comment's artifact in the `path` parameter
  or multiple sources encoded in JSON in `SOURCES` env param
  and base path in `path` parameter
- Supports `push`, `pull_request` and `pull_request_target` event types.
- Supports multiple content sources enabling comment customization
  based on PR details available within the workflow context

### Sample workflow

```yaml
name: example
on: pull_request, pull_request_target
jobs:
  example:
    name: example
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - run: mkdir -p output/
      - run: echo "This is fancy a comment" > output/results.txt
      - uses: actions/upload-artifact@v1
        with:
          name: results
          path: output
      - uses: actions/download-artifact@v1
        with:
          name: results
      - name: comment PR - single source
        uses: machine-learning-apps/pr-comment@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          path: results/results.txt
      - name: comment PR - multiple content sources
        uses: machine-learning-apps/pr-comment@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SOURCES: '["header.md", "${{ github.event.label.name }}.md", "footer.md"]'
          # workflows syntax doesn't allow array as action params, hence JSON via ENV
        with:
          path: .github/templates/
```
