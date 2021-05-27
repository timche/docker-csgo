import fs from "fs/promises";
import path from "path";
import got from "got";
import execa from "execa";

const serverSourceModPath = path.resolve(
  __dirname,
  "sourcemod",
  "server_sourcemod.sh"
);

async function upgradeMod(
  mod: string,
  downloadPageUrl: string,
  versionBuildNumberRegExp: RegExp,
  versionReplaceRegExp: RegExp,
  buildNumberReplaceRegExp: RegExp
) {
  const serverSourceModFile = await fs.readFile(serverSourceModPath, "utf-8");

  const { body } = await got(downloadPageUrl);

  const match = body.match(versionBuildNumberRegExp);

  if (match) {
    const [_, version, buildNumber] = match;
    let changedServerSourceModFile = serverSourceModFile.replace(
      versionReplaceRegExp,
      `$1${version}$2`
    );
    changedServerSourceModFile = serverSourceModFile.replace(
      buildNumberReplaceRegExp,
      `$1${buildNumber}$2`
    );

    if (serverSourceModFile === changedServerSourceModFile) {
      console.log(`no upgrade available for ${mod}`);
    } else {
      const commitMessage = `upgrade ${mod} to version ${version} build ${buildNumber}`;

      await fs.writeFile(serverSourceModPath, changedServerSourceModFile);

      if (process.env.CI === "true") {
        await execa("git", ["commit", "-am", commitMessage]);
        await execa("git", ["push"]);
      }

      console.log(commitMessage);
    }
  }
}

async function upgradeMods() {
  try {
    await upgradeMod(
      "sourcemod",
      "https://www.sourcemod.net/downloads.php?branch=stable",
      /<a class='quick-download download-link' href='https:\/\/sm\.alliedmods\.net\/smdrop\/\d+.\d+\/sourcemod-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
      /(\${SOURCEMOD_VERSION-")\d+\.\d+.\d+("}")/,
      /(\${SOURCEMOD_BUILD-)\d+(})/
    );

    await upgradeMod(
      "metamod",
      "https://www.sourcemm.net/downloads.php?branch=stable",
      /<a class='quick-download download-link' href='https:\/\/mms\.alliedmods\.net\/mmsdrop\/\d+.\d+\/mmsource-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
      /(\${METAMOD_VERSION-")\d+\.\d+.\d+("}")/,
      /(\${METAMOD_BUILD-)\d+(})/
    );
  } catch (error) {
    console.error(error?.message);
    process.exit(1);
  }
}

upgradeMods();
