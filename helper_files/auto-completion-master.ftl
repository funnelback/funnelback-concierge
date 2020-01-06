<#ftl encoding="utf-8" /><#compress>
<#--
auto-completion.ftl: This template is used to generate auto-completion CSV from the Funnelback index. This file is included as part of the funnelback-concierge GitHub project. See: https://github.com/funnelback/funnelback-concierge/
Author: Peter Levan, 2017
-->
<#import "/web/templates/modernui/funnelback_classic.ftl" as s/>
<#import "/web/templates/modernui/funnelback.ftl" as fb/>
<@s.Results>
<#assign displayJson>
<@compress single_line=true>
{
    "title": "${(s.result.title!"No title")?json_string}",
        <#if s.result.date?exists>"date": "${s.result.date?string["dd MMM YYYY"]?json_string}",</#if>
    "summary": "${s.result.summary!?json_string}",
    "fileSize": "${s.result.fileSize!?json_string}",
    "fileType": "${s.result.fileType!?json_string}",
    "exploreLink": "${s.result.exploreLink!?json_string}",
        "metaData": {
        <#if s.result.metaData??><#list s.result.metaData?keys as md>
            "${md?json_string}": "${s.result.metaData[md]?json_string}"<#if md_has_next>,</#if>
        </#list></#if>
    },
    "displayUrl": "${s.result.liveUrl!?json_string}",
    "cacheUrl": "${s.result.cacheUrl!?json_string}"
}
</@compress>
</#assign>
<#--Check to see if the action has been configured, URL mode directing to the ClickUrl is the default-->
<#assign configActionMode>question.collection.configuration.value("auto-completion.${question.profile?replace("_preview","")}.action-mode")</#assign>
<#assign configActionModeEval=configActionMode?eval!"U">
<#if configActionModeEval == "Q">
    <#assign actionmode = "Q">
<#else>
    <#assign actionmode = "U">
</#if>
<#if s.result.class.simpleName != "TierBar">
    <#-- read in a comma separated list of triggers from collection.cfg for each auto-completion profile.  Each trigger can be made up of multiple words sourced from
        different fields.  Profile is read from the profile CGI parameter when the auto-completion is generated.
        e.g. Configure three triggers for a staff record (profile=staff)
        auto-completion.staff.triggers=s.result.metaData["firstname"] s.result.metaData["lastname"],s.result.metaData["lastname"] s.result.metaData["firstname"],s.result.metaData["department"]
        e.g. Configure a single trigger for a news entry (profile=news)
        auto-completion.news.triggers=s.result.title
    -->
    <#assign triggerConfig>question.collection.configuration.value("auto-completion.${question.profile?replace("_preview","")}.triggers")</#assign>
    <#-- several compound triggers can be defined in the collection.cfg, separated with commas.  Split these and process each compound trigger -->
    <#if triggerConfig?eval??>
        <#assign triggerConfigList = triggerConfig?eval/>
    <#else>
        <#assign triggerConfigList = "s.result.title"/>
    </#if>
    <#list triggerConfigList?split(",") as triggerList>
        <#assign trigger = "">
        <#list triggerList?split(" ") as triggerVars>
            <#-- each (compound) trigger can be made from a set of values that are combined from different metadata.  Eval these vars and join with a space -->
            <#assign triggerClean = triggerVars?eval?lower_case?replace("[^A-Za-z0-9\\s]"," ","r")?replace("\\s+"," ","r")>
            <#assign trigger += triggerClean+" ">
        </#list>
        <#assign trigger=trigger?replace("\\s+$","","r")?replace("^\\s+","","r")>
        <#-- set up the action -->
        <#if actionmode == "Q">
            <#assign action = trigger>
        <#else>
            <#assign action = s.result.clickTrackingUrl>
        </#if>
        <#list trigger?split(" ") as x>
            <#-- process each trigger, stripping out stop words -->
            <#if response.customData["stopwords"]?? && response.customData["stopwords"]?seq_contains(x)>
                <#assign trigger>${trigger?replace("^"+x+"\\s+","","r")}</#assign>
            <#elseif trigger??>
                "${trigger}",900,${escapeCsv(displayJson)},J,"",,"${action}",${actionmode}
                <#assign trigger>${trigger?replace("^"+x+"\\s+","","r")}</#assign>
            </#if>
        </#list>
    </#list>
</#if>
</@s.Results>
</#compress>

<#function escapeCsv str>
    <#return str!?chop_linebreak?trim?replace("\\", "\\\\")?replace("\"", "\\\"")?replace(",","\\,") />
</#function>