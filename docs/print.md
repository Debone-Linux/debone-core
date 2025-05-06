---
title: Printable View
layout: default
nav_order: 999
print: true
---

{% assign top_pages = site.pages | where_exp: "p", "p.title and p.parent == nil and p.path != page.path" | sort: "nav_order" %}

# Table of Contents
<div class="toc">
  <ul>
  {% for chapter in top_pages %}
    <li><a href="#{{ chapter.title }}">{{ chapter.title }}</a></li>
  {% endfor %}
  </ul>
</div>

{% for chapter in top_pages %}
  <div id="{{ chapter.title }}" class="chapter">
    <h1>{{ chapter.title }}</h1>
    {{ chapter.content | markdownify }}

    {% assign sections = site.pages | where: "parent", chapter.title | sort: "nav_order" %}
    {% for section in sections %}
      <div id="{{ section.title }}" class="section">
        <h2>{{ section.title }}</h2>
        {{ section.content | markdownify }}

        {% assign subsections = site.pages | where: "parent", section.title | sort: "nav_order" %}
        {% for subsection in subsections %}
          <div class="subsection">
            <h3>{{ subsection.title }}</h3>
            {{ subsection.content | markdownify }}
          </div>
        {% endfor %}
      </div>
    {% endfor %}
  </div>
{% endfor %}
