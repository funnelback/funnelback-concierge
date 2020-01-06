<#ftl encoding="utf-8" />
<#if question.profile?exists>
    <#if question.profile?matches(".*_preview")>
        <#include "../_default_preview/auto-completion-master.ftl">
    <#else>
        <#include "../_default/auto-completion-master.ftl">
    </#if>
<#else>
    <#include "../_default/auto-completion-master.ftl">
</#if>
