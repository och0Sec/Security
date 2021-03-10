pip3 list --outdated --trusted-host pypi.org | cut -d " " -f1 | xargs -n1 pip3 install -U --trusted-host pypi.org --trusted-host files.pythonhosted.org
