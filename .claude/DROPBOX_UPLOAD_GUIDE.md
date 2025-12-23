# Dropbox Upload Guide

## Upload the Archive

### Step 1: Upload to Dropbox
1. Go to https://www.dropbox.com
2. Navigate to the folder where you want to store the archive
3. Upload `src/ArchiveBuilder/Output/UE_5.6_OculusDrop.7z` (19GB)
4. Wait for upload to complete

### Step 2: Get Shareable Link
1. Right-click on the uploaded file in Dropbox
2. Click "Share..." or "Copy link"
3. If prompted, set sharing to "Anyone with the link can view"
4. Copy the link - it will look like:
   ```
   https://www.dropbox.com/scl/fi/XXXXX/UE_5.6_OculusDrop.7z?rlkey=XXXXX&dl=0
   ```

### Step 3: Convert to Direct Download Link
Change `?dl=0` to `?dl=1` at the end of the URL:

**Preview link (shows Dropbox page):**
```
https://www.dropbox.com/scl/fi/XXXXX/UE_5.6_OculusDrop.7z?rlkey=XXXXX&dl=0
```

**Direct download link (for installer):**
```
https://www.dropbox.com/scl/fi/XXXXX/UE_5.6_OculusDrop.7z?rlkey=XXXXX&dl=1
```

### Step 4: Test the Link
1. Open a private/incognito browser window
2. Paste the direct download link (with `?dl=1`)
3. Verify it starts downloading immediately (not showing a preview page)

### Step 5: Save the URL
Once confirmed working, save the URL to:
```
EngineInstaller/src/AemulusEngineInstaller/DownloadConfig.txt
```

This will be used by the installer in Phase 2.

## Expected Upload Time

With typical broadband upload speeds:
- **10 Mbps upload**: ~4.5 hours
- **25 Mbps upload**: ~1.8 hours
- **50 Mbps upload**: ~50 minutes
- **100 Mbps upload**: ~25 minutes

## Troubleshooting

### Upload Fails or Stalls
- Try Dropbox desktop app instead of web interface
- Upload during off-peak hours
- Check available space (19GB of 2TB = 1%)

### Link Doesn't Work
- Verify `?dl=1` at the end (not `?dl=0`)
- Check sharing permissions (Anyone with link)
- Test in incognito/private browser

## Next Steps

After upload is complete and URL is tested:
1. Save the direct download URL
2. Proceed to Phase 2: Installer Development
3. Update installer to download from this URL
4. Test full installation flow
