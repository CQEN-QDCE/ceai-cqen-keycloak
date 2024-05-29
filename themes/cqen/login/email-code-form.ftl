<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "title">
        ${msg("accessCodeFormTitle")}
    <#elseif section = "header">
        ${msg("accessCodeFormTitle")}
    <#elseif section = "form">
        
        <form action="${url.loginAction}" class="${properties.kcFormClass!}" id="kc-u2f-login-form" method="post">
            <div class="h1"> ­­  <p>${msg("enterAccessCode")}</p> </div>
            <span for="sub-title-access-code">${msg("subTitleAccessCode")}</span>

            <div class="${properties.kcFormGroupClass!}"></div>
            <div class="${properties.kcFormGroupClass!}"></div>
            
            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                <input class="btn btn-link" name="resend" 
                   type="submit" value="${msg("resendCode")}"/>
                </div>
                <div class="input-access-code ${properties.kcInputWrapperClass!} ">
                    <input id="emailCode" name="emailCode" type="text" inputmode="number" maxlength="6" onkeypress='return event.charCode >= 48 && event.charCode <= 57'/>
                </div>
            </div>
            
            <div class="${properties.kcFormGroupClass!}"></div>
            <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                type="submit" value="${msg("doConnected")}"/>
            <input name="cancel"
                class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}"
                type="submit" value="${msg("doCancel")}"/>
        </form>
    </#if>
</@layout.registrationLayout>