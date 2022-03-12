#!/usr/bin/env python
# coding: utf-8

# # System Setup

# In[ ]:


get_ipython().run_line_magic('load_ext', 'autotime')


# In[ ]:


if with_pip_install:
    get_ipython().system(' pip install -q pip -U')
    get_ipython().system(' pip install -q matplotlib')
    get_ipython().system(' pip install -q pandas')
    get_ipython().system(' pip install -q cloudmesh-common -U')
    get_ipython().system(' pip install -q ipywidgets')


# In[2]:


import ipynbname
NOTEBOOK = ipynbname.name() + ".ipynb"


# In[3]:


get_ipython().system('jupyter trust $NOTEBOOK')


# In[4]:


user_id = get_ipython().getoutput('id -u')
group_id = get_ipython().getoutput('id -g')
user = get_ipython().getoutput('whoami')
user = user[0]
user_id = user_id[0]
group_id = group_id[0]


# In[ ]:




