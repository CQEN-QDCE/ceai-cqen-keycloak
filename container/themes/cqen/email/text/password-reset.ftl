<#ftl output_format="plainText">
${msg("messageBeforeMail")}

${msg("passwordResetBody",link, linkExpiration, realmName, linkExpirationFormatter(linkExpiration))}

${msg("messageAfterMail")}