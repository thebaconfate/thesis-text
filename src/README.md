# vub-thesis

# Adding template to an existing project.

```bash
# 1. Add the template repo as a remote
git remote add thesis-origin git@github.com:thebaconfate/texlive-vub.git

# 2. Fetch the specific branch
git fetch thesis-origin template-thesis

# 3. Read the branch content into a new directory, you can change the name of
# the directory
git read-tree --prefix=thesis/ -u thesis-origin/template-thesis

# 4. Commit the result
git commit -m "Add VUB thesis template"
```

# Using the template as a starting project

```bash
# Clone only the specific template branch into a new folder
git clone --branch template-thesis --single-branch https://github.com/thebaconfate/texlive-vub.git project/

# Remove the git connection so it's a fresh start
cd project/
rm -rf .git
git init
```

Alternatively you can use the github 'use this template' but this will require
more fuckery since it uses the default main branch, which will have to build the
templates. Afterwards you'll have to pull, switch and decouple main and
making the template the main. It's a lot easier to use the above commands
