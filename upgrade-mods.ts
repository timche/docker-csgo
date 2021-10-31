import fs from "fs/promises";
import path from "path";
import got from "got";
import execa from "execa";

const serverSourceModPath = path.resolve(
  __dirname,
  "sourcemod",
  "server_sourcemod.sh"
);

const readmePath = path.join(__dirname, "README.md");

async function upgradeMod({
  mod,
  downloadPageUrl,
  versionBuildNumberRegExp,
  versionReplaceRegExp,
  readmeVersionReplaceRegExp,
  buildNumberReplaceRegExp,
  readmeBuildNumberReplaceRegExp,
}: {
  mod: string;
  downloadPageUrl: string;
  versionBuildNumberRegExp: RegExp;
  versionReplaceRegExp: RegExp;
  readmeVersionReplaceRegExp: RegExp;
  buildNumberReplaceRegExp: RegExp;
  readmeBuildNumberReplaceRegExp: RegExp;
}) {
  const { body } = await got(downloadPageUrl);
  const match = body.match(versionBuildNumberRegExp);

  if (match) {
    const [_, version, buildNumber] = match;

    const serverSourceModFile = await fs.readFile(serverSourceModPath, "utf-8");
    const changedServerSourceModFile = serverSourceModFile
      .replace(versionReplaceRegExp, `$1${version}$2`)
      .replace(buildNumberReplaceRegExp, `$1${buildNumber}$2`);

    if (serverSourceModFile === changedServerSourceModFile) {
      console.log(`no upgrade available for ${mod}`);
    } else {
      const commitMessage = `upgrade ${mod} to version ${version} build ${buildNumber}`;

      await fs.writeFile(serverSourceModPath, changedServerSourceModFile);

      const readmeFile = await fs.readFile(readmePath, "utf-8");

      const changedReadmeFile = readmeFile
        .replace(readmeVersionReplaceRegExp, `$1${version}$2`)
        .replace(readmeBuildNumberReplaceRegExp, `$1${buildNumber}$2`);

      await fs.writeFile(readmePath, changedReadmeFile);

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
    await upgradeMod({
      mod: "sourcemod",
      downloadPageUrl: "https://www.sourcemod.net/downloads.php?branch=stable",
      versionBuildNumberRegExp: /<a class='quick-download download-link' href='https:\/\/sm\.alliedmods\.net\/smdrop\/\d+.\d+\/sourcemod-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
      versionReplaceRegExp: /(\${SOURCEMOD_VERSION-")\d+\.\d+.\d+("}")/,
      readmeVersionReplaceRegExp: /(##### `SOURCEMOD_VERSION`\n\n.+\n\nDefault: `)[0-9.]+(`)/,
      buildNumberReplaceRegExp: /(\${SOURCEMOD_BUILD-)\d+(})/,
      readmeBuildNumberReplaceRegExp: /(##### `SOURCEMOD_BUILD`\n\n.+\n\nDefault: `)[0-9]+(`)/,
    });

    await upgradeMod({
      mod: "metamod",
      downloadPageUrl: "https://www.sourcemm.net/downloads.php?branch=stable",
      versionBuildNumberRegExp: /<a class='quick-download download-link' href='https:\/\/mms\.alliedmods\.net\/mmsdrop\/\d+.\d+\/mmsource-(\d+.\d+.\d+)-git(\d+)-linux\.tar.gz'>/,
      versionReplaceRegExp: /(\${METAMOD_VERSION-")\d+\.\d+.\d+("}")/,
      readmeVersionReplaceRegExp: /(##### `METAMOD_VERSION`\n\n.+\n\nDefault: `)[0-9.]+(`)/,
      buildNumberReplaceRegExp: /(\${METAMOD_BUILD-)\d+(})/,
      readmeBuildNumberReplaceRegExp: /(##### `METAMOD_BUILD`\n\n.+\n\nDefault: `)[0-9]+(`)/,
    });
  } catch (error) {
    if (error instanceof Error) {
      console.error(error?.message);
    }

    process.exit(1);
  }
}

upgradeMods();
