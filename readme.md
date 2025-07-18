# 关于汉化
汉化基于原项目旧版本，直接修改代码内嵌文本而制作。
目前，我 (Bli_AIk) 不再维护此项目，因此此库已存档。
如果需要参考、使用此汉化，可以自行fork、构建。
我个人的汉化水平有限，汉化文本仅供参考。
感谢。

# 关于构建
以下信息为我初次构建此项目时，在自行尝试与询问项目作者 retronator 等方式下获取到的一些关于构建可能有帮助的信息。
这些信息是在旧版本下整理的，可能与目前版本的项目存在出入，仅供参考。

## 初次构建
- 你需要使用 Retronator fork 的 [meteor-desktop](https://github.com/Retronator/meteor-desktop)。这个库也需要先使用 'npm install'。
- 使用 'METEOR@2.16'
- 原作者使用 Mac 系统 开发，如果你使用 Windows 系统，glsl文件等可能会出现换行符差异，可以通过IDE设置或者[这个库](https://github.com/Retronator/Pixel-Art-Academy/blob/master/packages/api/glslbuildplugin.js)
- 如果遇到了[这个问题](https://github.com/Meteor-Community-Packages/meteor-desktop/issues/37)，可以尝试将 @babel/preset-env 版本降级到 7.7.1。

## 修改代码前：关闭缓存生成
你需要关闭缓存生成后才能使修改后的CoffeeScript文件生效。
在这里我直接贴出原作者与我私信的原文：

> The cache is generated from the contents in the database, you do that on the admin page
> http://localhost:3000/admin/artificial/mummification/documentcaches
> The contents in the database gets populated when you run the server at the start, from the various places text is in coffeescript files.
> If you want to bypass the use of the cache, then you change Artificial.Babel.inTranslationMode(true)
> When the game is in translation mode, it pickst up the text from the database instead of from the cache.
> So my workflow when adding new text is this:
> 1. Set translation mode to true in the babel-client.coffee file.
> 2. Change any texts in CoffeeScript files.
> 3. Restart the server so the texts get upserted into the database. Test the game and change more texts if needed.
> 4. When all texts are great, download the new cache from the admin page.
> 5. Replace the new cache in the public folder.
> 6. Disable translation mode. The texts will now be read from the cache on the client.
> 7. Make a new build with electron packager.

## 修改字体
字体文件路径[在这](https://github.com/Retronator/Pixel-Art-Academy/tree/learn-mode/packages/retronator-identity/typography)
修改css文件即可。

## 下载缓存文件
访问管理界面 (http://localhost:3000/admin/artificial/mummification/documentcaches)。你必须有一个包含管理员账户用户名/密码的 meteor 配置文件，这样管理员账户才会被创建。然后使用管理员账户登录此页面。参阅下文（原readme）的“高级设置”一节。

---


# Pixel Art Academy

An adventure game for learning how to draw.

Current live version: [pixelart.academy](https://pixelart.academy)

## Running

Install [Meteor](https://www.meteor.com):

```
curl https://install.meteor.com/ | sh
```

Checkout the repository and update npm dependecies:

```
meteor npm install
```

You're ready to go! Run with:

```
meteor
```

## Advanced setup 

If you want to configure extra features such as logging in with 
additional services, you will want to include a settings file.

You will also want to run on a custom domain that you set to your
localhost IP in the `/etc/hosts` file.

```
127.0.0.1       localhost.pixelart.academy
```

Then you can create a shell script to run the project with:

```
./run
```

contents of `run`:

```
export ROOT_URL=http://localhost.pixelart.academy:3000
meteor run --settings path/to/settings.json
```

contents of `settings.json`:

```
{
  "test": true,
  "admin":{
    "username":"admin",
    "password":"test",
    "email":"admin@test.com",
    "profile":{
      "name": "Administrator"
    }
  },
  "oauthSecretKey": "1234567890",
  "facebook": {
    "appId": "1234567890",
    "secret": "1234567890"
  },
  "twitter": {
    "consumerKey": "1234567890",
    "secret": "1234567890"
  },
  "google": {
    "clientId": "1234567890",
    "secret": "1234567890"
  },
  "amazonWebServices": {
    "accessKey": "1234567890",
    "secret": "1234567890"
  },
  "stripe": {
    "secretKey": "1234567890"
  },
  "public": {
    "stripe": {
      "publishableKey": "1234567890"
    },
    "google": {
      "analytics": "1234567890"
    }
  }
}
```

### Settings keys

private section:

| Key                  | Description                                                                |
|----------------------|----------------------------------------------------------------------------|
| test                 | Creates test users with different backer levels.                           |
| admin                | Creates an admin user with given login info.                               |
| oauthSecretKey       | Enables encryption of login services tokens.                               |
| facebook             | Enables logging in with Facebook.                                          |
| twitter              | Enables logging in with Twitter.                                           |
| google               | Enables logging in with Google.                                            |
| amazonWebServices    | Enables upload of artworks.                                                |
| stripe               | Enables Stripe payments (server side).                                     |

Public section:

| Key                  | Description                                                                |
|----------------------|----------------------------------------------------------------------------|
| stripe               | Enables Stripe payments (client side).                                     |
| google.analytics     | Enables Google Analytics.                                                  |
