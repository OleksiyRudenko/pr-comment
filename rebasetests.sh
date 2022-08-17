git delete-tag v1.2
git tagv v1.2
git branch -f test
git checkout test
git push -f
git checkout test-wf-1
git rebase test
git push -f
