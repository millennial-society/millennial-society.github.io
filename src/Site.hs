{-# LANGUAGE OverloadedStrings #-}

import Hakyll
import Hakyll.Web.Sass (sassCompiler)

import System.FilePath (takeFileName)

hakyllConfig :: Configuration
hakyllConfig = defaultConfiguration
    { destinationDirectory = "docs"
    , providerDirectory = "content"
    }

main :: IO ()
main = hakyllWith hakyllConfig $ do
    loadTemplates
    compileSass
    compileIndex

loadTemplates, compileSass, compileIndex :: Rules ()

loadTemplates = match "templates/*" $ compile templateBodyCompiler

compileSass = match "css/*.scss" $ do
    route $ setExtension "css"
    compile (fmap compressCss <$> sassCompiler)

compileIndex = match "pages/index.rst" $ do
    route (constRoute "index.html")
    compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/page.html" defaultContext
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

filenameOnlyRoute, htmlExtensionRoute :: Routes
filenameOnlyRoute = customRoute (takeFileName . toFilePath)

htmlExtensionRoute = setExtension "html"
