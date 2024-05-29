<#ftl output_format="plainText">
${msg("messageBeforeMail")}

${msg("emailVerificationBody",link, linkExpiration, realmName, linkExpirationFormatter(linkExpiration))}

${msg("messageAfterMail")}