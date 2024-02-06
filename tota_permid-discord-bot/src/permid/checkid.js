const { Client, GatewayIntentBits, SlashCommandBuilder, EmbedBuilder, ButtonBuilder, ButtonInteraction, ButtonComponent, ButtonStyle, ActionRowBuilder } = require('discord.js');
const { token, prefix, logo, hex_color, community_name, database_host, database_user, database_password, database_base, staff_roles } = require('../.././config.json');
const mysql = require('mysql')

var found = true

module.exports = {
	data: new SlashCommandBuilder()
		.setName('checkid')
		.setDescription('Checks Perm ID from Server User')
        .addStringOption(option =>
            option.setName('permid')
                .setDescription('The Perm ID to check')),
	async execute(interaction) {
        staff = false

        staff_roles.forEach(role => {
            if(interaction.member.roles.cache.get(role) != undefined) {
                staff = true
                return
            }
        });

        var con = mysql.createConnection({
            host: database_host,
            user: database_user,
            password: database_password,
            database: database_base
        })
        con.connect(function(err) {
            if (err) throw err;
        })
        
        const id = interaction.options.getString('permid');
        if(parseInt(id) == null || id.length < 1) {
            await interaction.reply('Please, introduce a valid Perm ID to check.')
            return
        }

		if (!staff) return;

        const perm_id = id
        var code = "SELECT * FROM users WHERE `permid` = '" + perm_id + "'";
        con.query(code, (err, resultc) => {  
            if(err) throw err;
            let response = resultc[0];
            if (resultc[0] == undefined) {
                if (staff) {
                    interaction.channel.send('`ID was not found.`')
                } else {
                    interaction.channel.send('`You do not have permission to use this command.`')
                }
                return
            }
            let identifier = response.identifier
            let accounts = JSON.parse(response.accounts)
            let group = response.group
            let job = response.job
            let job_grade = response.job_grade
            let loadout = response.loadout
            let firstname = response.firstname
            let lastname = response.lastname
            let created_at = new Date(response.created_at)
            let last_seen = new Date(response.last_seen)
            let discord = response.discord
            if (discord == null) {
                discord = 'NOT FOUND' 
            }else discord = '<@'+ discord + '> - ID ' + discord
            const info_embed = new EmbedBuilder()
                .setTitle("PERM ID: " + perm_id)
                .setAuthor({
                    name: "Requested by " + interaction.user.tag.toString(),
                    iconURL: interaction.user.displayAvatarURL()
                })
                .setColor(hex_color)
                .addFields(
                    { name: 'Identifier', value: identifier },
                    { name: 'Bank Balance', value: String(accounts['bank']), inline: true },
                    { name: 'Cash', value: String(accounts['money']), inline: true },
                    { name: 'Black Money', value: String(accounts['black_money']), inline: true },
                    { name: 'Permissions', value: group },
                    { name: 'Job', value: job, inline: true },
                    { name: 'Loadout', value: loadout },
                    { name: 'First Name', value: firstname, inline: true },
                    { name: 'Last Name', value: lastname, inline: true },
                    { name: 'First Logged in', value: '<t:'+ Math.floor(created_at.getTime() / 1000) + ':d>' },
                    { name: 'Last Logged in', value: '<t:'+ Math.floor(last_seen.getTime() / 1000) + ':d>' },
                    { name: 'Discord ID', value: discord },
                )
                .setFooter({
                    "text": `Made with ❤️ by Matota`,
                    "icon_url": `https://cdn.discordapp.com/attachments/1047512256495222834/1047635124444995686/tn-logo.png?ex=65bac4bd&is=65a84fbd&hm=b4e9655b18cb649e3f2893b008806e745a15849e7c796ebc894fd7d636c1964a&`
                }
            )
            if (staff) {
                interaction.channel.send({ embeds: [info_embed] });
            } else {
                interaction.channel.send('`You do not have permission to use this command.`')
            }
        })
        await interaction.reply('`Searching...`')
	},
};